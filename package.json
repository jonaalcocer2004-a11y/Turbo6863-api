   const express = require('express');
   const admin = require('firebase-admin');
   const cors = require('cors');
   const app = express();
   app.use(express.json());
   app.use(cors());

   const serviceAccount = JSON.parse(process.env.FIREBASE_KEY);
   admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
   const db = admin.firestore();

   app.post('/api/pedido', async (req, res) => {
     const pedidoId = 'T6863_' + Date.now();
     await db.collection('pedidos').doc(pedidoId).set(req.body);
     res.json({ success: true, pedidoId });
   });

   app.get('/api/pedidos', async (req, res) => {
     const snapshot = await db.collection('pedidos').get();
     res.json(snapshot.docs.map(doc => doc.data()));
   });

   const PORT = process.env.PORT || 3000;
   app.listen(PORT, () => console.log('TURBO 6863 OK'));
