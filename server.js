const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const mercadopago = require('mercadopago'); // <-- AGREGUÉ ESTA LÍNEA 6863

const app = express();
app.use(cors());
app.use(express.json());

const SUPABASE_URL = 'https://dzwxnpqtvegwujinyrrz.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6d3hucHRxdmVnd3VpamlueXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI2NzMxOTksImV4cCI6MjA5ODI0OTE5OX0.QCNVxKxBP5TggjtUjTC1wzN02E--fphl-9NqVtqdHbQ';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

// CONFIG DE MERCADO PAGO 6863
mercadopago.configure({
  access_token: process.env.MP_ACCESS_TOKEN
});

app.get('/', (req, res) => {
  res.json({ estado: 'En vivo 6863', mensaje: 'Turbo6863-api funcionando' });
});

app.post('/pedidos', async (req, res) => {
  const { data, error } = await supabase.from('pedidos').insert([req.body]).select();
  if (error) return res.status(500).json({ error: error.message });
  res.json(data[0]);
});

app.get('/pedidos', async (req, res) => {
  const { data, error } = await supabase.from('pedidos').select('*').order('created_at', { ascending: false });
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

// RUTA NUEVA PARA SPLIT DE MP 6863
app.get('/reserve', async (req, res) => {
  const rest_id = req.query.rest_id;
  const total = req.query.total || 200;

  if (!rest_id) {
    return res.status(400).json({ error: 'Falta rest_id 6863' });
  }

  const preference = {
    items: [{
      title: `Pedido Turbo 6863`,
      quantity: 1,
      unit_price: parseFloat(total),
      currency_id: 'MXN'
    }],
    marketplace_fee: 40,
    collector_id: parseInt(rest_id),
    back_urls: {
      success: `https://turbo6863.onrender.com/success`,
      failure: `https://turbo6863.onrender.com/fail`
    },
    auto_return: "approved"
  };

  try {
    const response = await mercadopago.preferences.create(preference);
    res.json({
      link: response.body.init_point,
      msg: 'Link generado 6863'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API 6863 ONLINE`));
