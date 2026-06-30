-- ========================================================
-- SETUP DATABASE TURBO 6863 CON POSTGIS
-- ========================================================

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================================
-- TABLA: USUARIOS
-- ========================================================

CREATE TABLE IF NOT EXISTS usuarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  telefono VARCHAR(20),
  contraseña_hash VARCHAR(255) NOT NULL,
  tipo_usuario VARCHAR(50) NOT NULL CHECK (tipo_usuario IN ('cliente', 'oveja', 'restaurante', 'admin')),
  avatar_url TEXT,
  estado VARCHAR(30) DEFAULT 'activo',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_tipo ON usuarios(tipo_usuario);

-- ========================================================
-- TABLA: UBICACIONES OVEJAS
-- ========================================================

CREATE TABLE IF NOT EXISTS ubicaciones_ovejas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  oveja_id UUID NOT NULL UNIQUE REFERENCES usuarios(id) ON DELETE CASCADE,
  coordenadas GEOMETRY(Point, 4326) NOT NULL,
  velocidad NUMERIC(10, 2) DEFAULT 0,
  direccion VARCHAR(255),
  estado VARCHAR(20) DEFAULT 'disponible' CHECK (estado IN ('disponible', 'en_ruta', 'descansando', 'offline')),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ovejas_coordenadas ON ubicaciones_ovejas USING gist(coordenadas);
CREATE INDEX IF NOT EXISTS idx_ovejas_estado ON ubicaciones_ovejas(estado);

-- ========================================================
-- TABLA: RESTAURANTES
-- ========================================================

CREATE TABLE IF NOT EXISTS restaurantes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  propietario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  ubicacion GEOMETRY(Point, 4326) NOT NULL,
  direccion VARCHAR(255) NOT NULL,
  telefono VARCHAR(20),
  horario_apertura TIME,
  horario_cierre TIME,
  foto_url TEXT,
  rating NUMERIC(3, 2) DEFAULT 0,
  estado VARCHAR(20) DEFAULT 'abierto',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_restaurantes_ubicacion ON restaurantes USING gist(ubicacion);
CREATE INDEX IF NOT EXISTS idx_restaurantes_propietario ON restaurantes(propietario_id);

-- ========================================================
-- TABLA: MENU
-- ========================================================

CREATE TABLE IF NOT EXISTS menu (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurante_id UUID NOT NULL REFERENCES restaurantes(id) ON DELETE CASCADE,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  precio NUMERIC(10, 2) NOT NULL,
  foto_url TEXT,
  categoria VARCHAR(100),
  disponible BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_menu_restaurante ON menu(restaurante_id);
CREATE INDEX IF NOT EXISTS idx_menu_disponible ON menu(disponible);

-- ========================================================
-- TABLA: PEDIDOS
-- ========================================================

CREATE TABLE IF NOT EXISTS pedidos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  restaurante_id UUID NOT NULL REFERENCES restaurantes(id) ON DELETE CASCADE,
  oveja_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  origen_coordenadas GEOMETRY(Point, 4326) NOT NULL,
  destino_coordenadas GEOMETRY(Point, 4326) NOT NULL,
  direccion_destino VARCHAR(255) NOT NULL,
  total NUMERIC(10, 2) NOT NULL,
  estado VARCHAR(30) DEFAULT 'creado' CHECK (estado IN ('creado', 'confirmado', 'preparando', 'listo_cocina', 'en_camino', 'entregado', 'cancelado')),
  tiempo_estimado_entrega INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_restaurante ON pedidos(restaurante_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_oveja ON pedidos(oveja_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_estado ON pedidos(estado);

-- ========================================================
-- TABLA: ITEMS PEDIDO
-- ========================================================

CREATE TABLE IF NOT EXISTS items_pedido (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id UUID NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
  menu_id UUID NOT NULL REFERENCES menu(id),
  cantidad INTEGER NOT NULL DEFAULT 1,
  precio_unitario NUMERIC(10, 2) NOT NULL,
  notas TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_items_pedido ON items_pedido(pedido_id);

-- ========================================================
-- TABLA: PAGOS
-- ========================================================

CREATE TABLE IF NOT EXISTS pagos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id UUID NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
  usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  monto NUMERIC(10, 2) NOT NULL,
  metodo VARCHAR(50) NOT NULL CHECK (metodo IN ('mercado_pago', 'tarjeta', 'efectivo', 'billetera')),
  estado VARCHAR(30) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'procesando', 'completado', 'fallido', 'reembolsado')),
  transaccion_id VARCHAR(255),
  referencia_mp VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pagos_pedido ON pagos(pedido_id);
CREATE INDEX IF NOT EXISTS idx_pagos_usuario ON pagos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_pagos_estado ON pagos(estado);

-- ========================================================
-- TABLA: RESEÑAS
-- ========================================================

CREATE TABLE IF NOT EXISTS resenas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id UUID NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
  usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo_resena VARCHAR(50) NOT NULL CHECK (tipo_resena IN ('restaurante', 'repartidor')),
  id_resena UUID REFERENCES usuarios(id) ON DELETE CASCADE,
  calificacion INTEGER NOT NULL CHECK (calificacion >= 1 AND calificacion <= 5),
  comentario TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_resenas_pedido ON resenas(pedido_id);
CREATE INDEX IF NOT EXISTS idx_resenas_usuario ON resenas(usuario_id);

-- ========================================================
-- TABLA: HISTORIAL IA
-- ========================================================

CREATE TABLE IF NOT EXISTS historial_ia (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
  pedido_id UUID REFERENCES pedidos(id) ON DELETE CASCADE,
  mensaje_cliente TEXT NOT NULL,
  respuesta_bot TEXT NOT NULL,
  alerta_generada BOOLEAN DEFAULT false,
  tipo_alerta VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_historial_ia_usuario ON historial_ia(usuario_id);
CREATE INDEX IF NOT EXISTS idx_historial_ia_pedido ON historial_ia(pedido_id);

-- ========================================================
-- TABLA: LOGS
-- ========================================================

CREATE TABLE IF NOT EXISTS logs_sistema (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo_evento VARCHAR(100) NOT NULL,
  usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
  pedido_id UUID REFERENCES pedidos(id) ON DELETE SET NULL,
  descripcion TEXT,
  datos_json JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_logs_tipo ON logs_sistema(tipo_evento);
CREATE INDEX IF NOT EXISTS idx_logs_fecha ON logs_sistema(created_at);

-- ========================================================
-- FUNCIONES POSTGIS
-- ========================================================

CREATE OR REPLACE FUNCTION buscar_ovejas_cercanas(
  p_longitud DOUBLE PRECISION,
  p_latitud DOUBLE PRECISION,
  p_radio_metros DOUBLE PRECISION
)
RETURNS TABLE (
  oveja_id UUID,
  nombre VARCHAR,
  distancia_metros DOUBLE PRECISION,
  estado VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    uo.oveja_id,
    u.nombre,
    ST_Distance(
      uo.coordenadas,
      ST_SetSRID(ST_MakePoint(p_longitud, p_latitud), 4326),
      true
    ) AS distancia_metros,
    uo.estado
  FROM ubicaciones_ovejas uo
  JOIN usuarios u ON uo.oveja_id = u.id
  WHERE
    uo.estado = 'disponible'
    AND ST_DWithin(
      uo.coordenadas,
      ST_SetSRID(ST_MakePoint(p_longitud, p_latitud), 4326),
      p_radio_metros,
      true
    )
  ORDER BY distancia_metros ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION restaurantes_cercanos(
  p_longitud DOUBLE PRECISION,
  p_latitud DOUBLE PRECISION,
  p_radio_metros DOUBLE PRECISION,
  p_limite INTEGER DEFAULT 20
)
RETURNS TABLE (
  restaurante_id UUID,
  nombre VARCHAR,
  distancia_metros DOUBLE PRECISION,
  rating NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.nombre,
    ST_Distance(
      r.ubicacion,
      ST_SetSRID(ST_MakePoint(p_longitud, p_latitud), 4326),
      true
    ) AS distancia_metros,
    r.rating
  FROM restaurantes r
  WHERE
    r.estado = 'abierto'
    AND ST_DWithin(
      r.ubicacion,
      ST_SetSRID(ST_MakePoint(p_longitud, p_latitud), 4326),
      p_radio_metros,
      true
    )
  ORDER BY distancia_metros ASC
  LIMIT p_limite;
END;
$$ LANGUAGE plpgsql;

-- ========================================================
-- TRIGGERS
-- ========================================================

CREATE OR REPLACE FUNCTION actualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_usuarios_updated BEFORE UPDATE ON usuarios
FOR EACH ROW EXECUTE FUNCTION actualizar_timestamp();

CREATE TRIGGER trigger_restaurantes_updated BEFORE UPDATE ON restaurantes
FOR EACH ROW EXECUTE FUNCTION actualizar_timestamp();

CREATE TRIGGER trigger_pedidos_updated BEFORE UPDATE ON pedidos
FOR EACH ROW EXECUTE FUNCTION actualizar_timestamp();

CREATE TRIGGER trigger_pagos_updated BEFORE UPDATE ON pagos
FOR EACH ROW EXECUTE FUNCTION actualizar_timestamp();

GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO authenticated;