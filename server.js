const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const mercadopago = require('mercadopago');

const app = express();
app.use(cors());
app.use(express.json());

// SUPABASE
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

// MERCADOPAGO
mercadopago.configure({
  access_token: process.env.MP_ACCESS_TOKEN
});

// STATUS
app.get('/', (req, res) => {
  res.json({
    estado: 'ONLINE 6863',
    api: 'Turbo6863',
    version: '1.0.0'
  });
});

// RESERVE CON SPLIT
app.get('/reserve', async (req, res) => {
  try {
    const rest_id = req.query.rest_id;
    const total = Number(req.query.total || 200);

    if (!rest_id) {
      return res.status(400).json({ error: 'Falta rest_id 6863' });
    }

    const preference = {
      items: [{
        title: 'Pedido Turbo 6863',
        quantity: 1,
        unit_price: total,
        currency_id: 'MXN'
      }],
      marketplace_fee: 40,
      collector_id: parseInt(rest_id),
      back_urls: {
        success: 'https://turbo6863.onrender.com/success',
        failure: 'https://turbo6863.onrender.com/fail',
        pending: 'https://turbo6863.onrender.com/pending'
      },
      auto_return: 'approved'
    };

    const response = await mercadopago.preferences.create(preference);
    res.json({ link: response.body.init_point, msg: 'Link generado 6863' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log('🔥 API 6863 ONLINE EN PUERTO', PORT);
});
