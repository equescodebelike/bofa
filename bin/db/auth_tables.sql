-- Table for storing email verification codes
CREATE TABLE IF NOT EXISTS "verification_codes" (
  "id" SERIAL PRIMARY KEY,
  "email" VARCHAR(255) NOT NULL,
  "code" VARCHAR(10) NOT NULL,
  "expires_at" TIMESTAMP NOT NULL,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for storing refresh tokens
CREATE TABLE IF NOT EXISTS "refresh_tokens" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INTEGER NOT NULL REFERENCES "User"(user_id),
  "token" VARCHAR(255) NOT NULL,
  "expires_at" TIMESTAMP NOT NULL,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS "idx_verification_codes_email" ON "verification_codes" ("email");
CREATE INDEX IF NOT EXISTS "idx_verification_codes_code" ON "verification_codes" ("code");
CREATE INDEX IF NOT EXISTS "idx_refresh_tokens_user_id" ON "refresh_tokens" ("user_id");
CREATE INDEX IF NOT EXISTS "idx_refresh_tokens_token" ON "refresh_tokens" ("token");
