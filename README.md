# 🚀 TURBO 6863 - CYBER AGENT DELIVERY

**Red logística cyberpunk con IA TURBO-BOT 6863** 🤖⚡

Plataforma de delivery de comidas tipo Rappi con sistema de IA avanzado, geolocalización en tiempo real y panel de control central.

---

## 📋 Características

✅ **Sistema de IA (TURBO-BOT 6863)**
- Gemini 1.5 Flash para atención al cliente
- Soporte inteligente y alertas automáticas

✅ **Geolocalización en Tiempo Real**
- PostGIS para cálculos de distancia
- Mapas interactivos con Leaflet
- Búsqueda automática de repartidores cercanos

✅ **Sistema de Pagos**
- Integración Mercado Pago
- Soporte para múltiples métodos

✅ **Comunicación en Tiempo Real**
- Socket.io para updates instantáneos
- Notificaciones push

✅ **Arquitectura PWA**
- Funciona offline
- Instalable en móviles
- Service Worker integrado

---

## 🛠️ Requisitos

- Node.js 18+
- npm o yarn
- PostgreSQL con PostGIS
- Supabase Account
- Google Generative AI API Key
- Mercado Pago Account

---

## 📦 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/jonaalcocer2004-a11y/Turbo6863-api.git
cd Turbo6863-api
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Configurar variables de entorno

```bash
cp .env.example .env
```

Edita `.env` con tus credenciales.

### 4. Setup de Base de Datos

```bash
psql postgresql://[user]:[password]@[host]/[db]
\i database_setup.sql
```

### 5. Iniciar servidor

```bash
npm run dev
```

Servidor corriendo en: **http://localhost:3000**

---

## 🎉 Listo!

**La plataforma TURBO 6863 está lista para desarrollo.**