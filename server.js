const express = require('express');
const cors = require('cors');
const app = express();

app.use(express.json());
app.use(cors());

app.get('/', (req, res) => {
  res.json({
    status: 'Live 6863',
    message: 'Turbo6863-api funcionando 🚀'
  });
});

app.post('/api/pedido', (req, res) => {
  const pedidoId = 'T6863_' + Date.now();
  res.json({ success: true, pedidoId, data: req.body });
});

app.get('/api/pedidos', (req, res) => {
  res.json([{ pedidoId: 'T6863_ejemplo', test: true }]);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log('TURBO 6863 OK'));
