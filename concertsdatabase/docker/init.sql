-- Drop All Tables (for clean start)
DROP TABLE IF EXISTS withdraw_requests, auto_withdraw, bookings, partner_rewards, sales_by_source, sales_reports, commissions, content_templates, banners, concerts, categories, partner_balances, partners, users CASCADE;

-- partners
CREATE TABLE partners (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    api_key VARCHAR(255) UNIQUE NOT NULL,
    token_key VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE partner_balances (
    partner_id INT PRIMARY KEY REFERENCES partners(id),
    balance FLOAT NOT NULL DEFAULT 0
);

-- categories
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- concerts
CREATE TABLE concerts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    partner_id INT REFERENCES partners(id),
    category_id INT REFERENCES categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_concerts_modtime()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_concerts_modtime
BEFORE UPDATE ON concerts
FOR EACH ROW
EXECUTE FUNCTION update_concerts_modtime();

-- banners
CREATE TABLE banners (
    id SERIAL PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    link VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_banners_modtime()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_banners_modtime
BEFORE UPDATE ON banners
FOR EACH ROW
EXECUTE FUNCTION update_banners_modtime();

-- content_templates
CREATE TABLE content_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_content_templates_modtime()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_content_templates_modtime
BEFORE UPDATE ON content_templates
FOR EACH ROW
EXECUTE FUNCTION update_content_templates_modtime();

-- commissions
CREATE TABLE commissions (
    id SERIAL PRIMARY KEY,
    partner_id INT REFERENCES partners(id),
    amount FLOAT NOT NULL,
    date_from DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- sales_reports
CREATE TABLE sales_reports (
    product VARCHAR(255) NOT NULL,
    amount FLOAT NOT NULL,
    sales_date TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE sales_by_source (
    source VARCHAR(255) NOT NULL,
    total_sales FLOAT NOT NULL
);

-- partner_rewards
CREATE TABLE partner_rewards (
    reward_id SERIAL PRIMARY KEY,
    amount FLOAT NOT NULL,
    partner_id INT REFERENCES partners(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- bookings
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    concert_id INT REFERENCES concerts(id),
    partner_id INT REFERENCES partners(id),
    tickets INT NOT NULL,
    amount FLOAT NOT NULL,
    booking_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    date DATE
);

-- auto update date field
CREATE OR REPLACE FUNCTION update_booking_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date = NEW.booking_at::date;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_booking_date
BEFORE INSERT OR UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION update_booking_date();

-- auto_withdraw
CREATE TABLE auto_withdraw (
    partner_id INT PRIMARY KEY REFERENCES partners(id),
    enabled BOOLEAN NOT NULL DEFAULT FALSE
);


-- withdraw_requests
CREATE TABLE withdraw_requests (
    id SERIAL PRIMARY KEY,
    partner_id INT REFERENCES partners(id),
    amount FLOAT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    api_key TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_users_modtime()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_modtime
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_users_modtime();

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_name ON users(name);

-- Table สำหรับเก็บ user
CREATE TABLE datauser( 
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table สำหรับเก็บ token
CREATE TABLE tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES datauser(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    is_valid BOOLEAN DEFAULT TRUE, -- ถ้า logout หรือ revoke จะ set false
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expired_at TIMESTAMP NOT NULL -- JWT หรือ token หมดอายุ
);

-- Index ช่วยเรื่อง performance
CREATE INDEX idx_tokens_user_id ON tokens(user_id);
CREATE INDEX idx_tokens_token ON tokens(token);



CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    endpoint TEXT NOT NULL,
    method TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES datauser(id)
);

CREATE TABLE data (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL  
);

-- -----------------------------
-- Sample Data
-- -----------------------------

INSERT INTO categories (name) VALUES ('Rock'), ('Pop');

INSERT INTO partners (name, api_key, token_key) VALUES
('Partner A', 'apikey_a', 'token_a'),
('Partner B', 'apikey_b', 'token_b');

INSERT INTO partner_balances (partner_id, balance) VALUES
(1, 0), (2, 0);

INSERT INTO concerts (name, location, date, partner_id, category_id) VALUES
('MY FIRST STORY ASIA TOUR 2025 IN BANGKOK', 'ธันเดอร์โดม เมืองทองธานี', '2025-07-12 19:00:00', 1, 1),
('Tyler, The Creator - CHROMAKOPIA : THE WORLD TOUR', 'อิมแพ็ค อารีน่า', '2025-09-16 18:00:00', 2, 2);

INSERT INTO users (name, email) VALUES
('ศศิมา พังยาง', 'sasima@example.com');

INSERT INTO banners (image_url, link) VALUES
('https://cdn.example.com/banner1.jpg', 'https://partner-a.com/promotion'),
('https://cdn.example.com/banner2.jpg', 'https://partner-b.com/event');

INSERT INTO content_templates (name, description) VALUES
('Standard Template', 'Basic content template for concert promotion'),
('Premium Template', 'Premium content template with rich media');

INSERT INTO commissions (partner_id, amount, date_from) VALUES
(1, 500.00, '2025-04-01'),
(2, 800.00, '2025-04-01');

INSERT INTO sales_reports (product, amount, sales_date) VALUES
('Concert 1 Ticket', 3000.00, '2025-04-01 10:00:00'),
('Concert 2 Ticket', 4500.00, '2025-04-02 11:00:00');

INSERT INTO sales_by_source (source, total_sales) VALUES
('Facebook Ads', 4000.00),
('Google Ads', 3500.00);

INSERT INTO partner_rewards (amount, partner_id) VALUES
(100.00, 1),
(200.00, 2);

INSERT INTO bookings (concert_id, partner_id, tickets, amount, booking_at) VALUES
(1, 1, 2, 2000.00, '2025-04-05 14:00:00'),
(2, 2, 1, 4500.00, '2025-04-06 16:00:00');

INSERT INTO withdraw_requests (partner_id, amount) VALUES
(1, 1000.00),
(2, 1500.00);

INSERT INTO auto_withdraw (partner_id, enabled)
SELECT 1, TRUE
WHERE NOT EXISTS (SELECT 1 FROM auto_withdraw WHERE partner_id = 1);


INSERT INTO datauser (email, password, name, phone)
VALUES ('sandta@example.com', 'sandta_password_123', 'sandta', '0812345678')
RETURNING id;

INSERT INTO tokens (user_id, token, expired_at)
VALUES (1, 'generated-jwt-token', NOW() + INTERVAL '1 day')
RETURNING id;

