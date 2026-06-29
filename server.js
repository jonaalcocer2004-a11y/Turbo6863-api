app.get('/reserve', async (req, res) => {
  try {
    const rest_id = req.query.rest_id;
    const total = Number(req.query.total || 200);

    if (!rest_id) {
      return res.status(400).json({ error: 'Falta rest_id 6863' });
    }

    const preference = {
      items: [
        {
          title: 'Pedido Turbo 6863',
          quantity: 1,
          unit_price: total,
          currency_id: 'MXN'
        }
      ],
      marketplace_fee: 40, // ← TU COMISIÓN FIJA 6863
      collector_id: parseInt(rest_id), // ← ID DEL RESTAURANTE
      back_urls: {
        success: 'https://turbo6863.onrender.com/success',
        failure: 'https://turbo6863.onrender.com/fail',
        pending: 'https://turbo6863.onrender.com/pending'
      },
      auto_return: 'approved'
    };

    const response = await mercadopago.preferences.create(preference);

    res.json({
      link: response.body.init_point,
      msg: 'Link generado 6863'
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
