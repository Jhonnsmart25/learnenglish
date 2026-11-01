require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Stripe = require('stripe');

const { STRIPE_SECRET_KEY, STRIPE_PRICE_ID } = process.env;
const PORT = process.env.PORT || 4242;
const BASE_URL = process.env.BASE_URL || `http://localhost:${PORT}`;
const TRIAL_DAYS = 7;

if (!STRIPE_SECRET_KEY || !STRIPE_PRICE_ID) {
  console.error('Falta STRIPE_SECRET_KEY o STRIPE_PRICE_ID en el archivo .env');
  process.exit(1);
}

const stripe = new Stripe(STRIPE_SECRET_KEY);
const app = express();
app.use(cors());
app.use(express.json());

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const normalizeEmail = (e) =>
  typeof e === 'string' ? e.trim().toLowerCase() : '';

async function findCustomers(email) {
  const res = await stripe.customers.list({ email, limit: 10 });
  return res.data;
}

// Estados que dan acceso: en prueba o pagando.
const ACCESS_STATUSES = ['trialing', 'active'];

// 1) Crea la sesión de pago con 7 días gratis.
app.post('/create-checkout-session', async (req, res) => {
  const email = normalizeEmail(req.body.email);
  if (!EMAIL_RE.test(email)) {
    return res.status(400).json({ error: 'Correo no válido' });
  }
  try {
    // Si ya tiene suscripción vigente, no se vuelve a cobrar ni a dar otra prueba.
    for (const c of await findCustomers(email)) {
      const subs = await stripe.subscriptions.list({
        customer: c.id,
        status: 'all',
        limit: 10,
      });
      if (subs.data.some((s) => ACCESS_STATUSES.includes(s.status))) {
        return res
          .status(409)
          .json({ error: 'Ya tienes una suscripción activa con ese correo.' });
      }
    }

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer_email: email,
      line_items: [{ price: STRIPE_PRICE_ID, quantity: 1 }],
      subscription_data: { trial_period_days: TRIAL_DAYS },
      payment_method_collection: 'always', // pide la tarjeta desde el inicio
      success_url: `${BASE_URL}/success`,
      cancel_url: `${BASE_URL}/cancel`,
    });
    res.json({ url: session.url });
  } catch (err) {
    console.error('create-checkout-session:', err.message);
    res.status(500).json({ error: 'No se pudo crear la sesión de pago' });
  }
});

// 2) La app pregunta si el correo tiene acceso.
app.get('/subscription-status', async (req, res) => {
  const email = normalizeEmail(req.query.email);
  if (!EMAIL_RE.test(email)) {
    return res.status(400).json({ error: 'Correo no válido' });
  }
  try {
    for (const c of await findCustomers(email)) {
      const subs = await stripe.subscriptions.list({
        customer: c.id,
        status: 'all',
        limit: 10,
      });
      const ok = subs.data.find((s) => ACCESS_STATUSES.includes(s.status));
      if (ok) return res.json({ active: true, status: ok.status });
    }
    res.json({ active: false });
  } catch (err) {
    console.error('subscription-status:', err.message);
    res.status(500).json({ error: 'No se pudo verificar la suscripción' });
  }
});

// 3) Portal de Stripe: el usuario cancela o cambia su tarjeta.
app.post('/create-portal-session', async (req, res) => {
  const email = normalizeEmail(req.body.email);
  if (!EMAIL_RE.test(email)) {
    return res.status(400).json({ error: 'Correo no válido' });
  }
  try {
    const customers = await findCustomers(email);
    if (customers.length === 0) {
      return res.status(404).json({ error: 'No encontramos tu cuenta' });
    }
    const session = await stripe.billingPortal.sessions.create({
      customer: customers[0].id,
      return_url: BASE_URL,
    });
    res.json({ url: session.url });
  } catch (err) {
    console.error('create-portal-session:', err.message);
    res.status(500).json({ error: 'No se pudo abrir el portal' });
  }
});

const page = (title, body) => `<!doctype html><html lang="es"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${title}</title>
<style>body{font-family:system-ui,sans-serif;text-align:center;padding:15vh 24px;color:#222}h1{margin-bottom:8px}</style>
</head><body><h1>${title}</h1><p>${body}</p></body></html>`;

app.get('/success', (_req, res) =>
  res.send(
    page(
      '¡Listo! 🎉',
      'Tu prueba gratis comenzó. Regresa a la app y toca “Ya me suscribí, entrar”.'
    )
  )
);
app.get('/cancel', (_req, res) =>
  res.send(page('Pago cancelado', 'No se hizo ningún cobro. Puedes regresar a la app.'))
);
app.get('/health', (_req, res) => res.json({ ok: true }));

app.listen(PORT, () => console.log(`Servidor listo en ${BASE_URL}`));
