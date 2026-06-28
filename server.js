const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(cors());
app.use(express.json());

const SUPABASE_URL = 'https://dzwxnpqtvegwujinyrrz.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6d3hucHRxdmVnd3VpamlueXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI2NzMxOTksImV4cCI6MjA5ODI0OTE5OX0.QCNVxKxBP5TggjtUjTC1wzN02E--fphl-9NqVtqdHbQ';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API 6863 ONLINE`));
