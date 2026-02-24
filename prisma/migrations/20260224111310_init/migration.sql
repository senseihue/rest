CREATE TYPE "payment_status" AS ENUM (
  'success',
  'pending',
  'hold',
  'rejected'
);

CREATE TYPE "transaction_type" AS ENUM (
  'reservation',
  'warehouse'
);

CREATE TYPE "transaction_status" AS ENUM (
  'success',
  'unsuccess',
  'pending'
);

CREATE TYPE "attachment_days" AS ENUM (
  'Mo',
  'Tu',
  'We',
  'Th',
  'Fr',
  'St',
  'Su'
);

CREATE TABLE "users" (
                         "id" integer PRIMARY KEY,
                         "email" varchar,
                         "password" varchar,
                         "login" varchar,
                         "restaurant_id" int
);

CREATE TABLE "restaurants" (
                               "id" integer PRIMARY KEY,
                               "name" varchar,
                               "location" varchar,
                               "opening" datetime,
                               "closing" datetime
);

CREATE TABLE "menus" (
                         "id" integer PRIMARY KEY,
                         "name" varchar,
                         "attached_day" attachment_days,
                         "restaurant_id" integer
);

CREATE TABLE "foods" (
                         "id" integer PRIMARY KEY,
                         "menu_id" integer,
                         "name" varchar NOT NULL,
                         "description" varchar,
                         "price" integer
);

CREATE TABLE "food_ingredients" (
                                    "id" int PRIMARY KEY,
                                    "food_id" int,
                                    "ingredient_id" int
);

CREATE TABLE "food_features" (
                                 "id" int PRIMARY KEY,
                                 "name" varchar,
                                 "food_id" int
);

CREATE TABLE "ingredient_categories" (
                                         "id" int PRIMARY KEY,
                                         "name" varchar
);

CREATE TABLE "ingredients" (
                               "id" integer PRIMARY KEY,
                               "name" varchar,
                               "category_id" integer
);

CREATE TABLE "reservations" (
                                "id" integer PRIMARY KEY,
                                "restaurant_id" int,
                                "user_id" int,
                                "reservation_time" date,
                                "place_id" int
);

CREATE TABLE "places" (
                          "id" integer PRIMARY KEY,
                          "number" varchar,
                          "seats" integer,
                          "restaurant_id" integer
);

CREATE TABLE "transactions" (
                                "id" integer,
                                "source_type" transaction_type,
                                "source_id" integer,
                                "payment_id" int,
                                "amount" integer,
                                "status" transaction_status,
                                "description" varchar,
                                PRIMARY KEY ("id", "payment_id")
);

CREATE TABLE "payments" (
                            "id" int PRIMARY KEY,
                            "amount" int,
                            "status" payment_status,
                            "description" varchar
);

CREATE TABLE "authorization_token" (
                                       "id" int PRIMARY KEY,
                                       "token" varchar,
                                       "expire_date" timestamp,
                                       "user_id" int
);

ALTER TABLE "menus" ADD FOREIGN KEY ("restaurant_id") REFERENCES "restaurants" ("id");

ALTER TABLE "foods" ADD FOREIGN KEY ("menu_id") REFERENCES "menus" ("id");

ALTER TABLE "reservations" ADD FOREIGN KEY ("restaurant_id") REFERENCES "restaurants" ("id");

ALTER TABLE "places" ADD FOREIGN KEY ("restaurant_id") REFERENCES "restaurants" ("id");

ALTER TABLE "reservations" ADD FOREIGN KEY ("place_id") REFERENCES "places" ("id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("payment_id") REFERENCES "payments" ("id");

ALTER TABLE "food_features" ADD FOREIGN KEY ("food_id") REFERENCES "foods" ("id");

ALTER TABLE "users" ADD FOREIGN KEY ("restaurant_id") REFERENCES "restaurants" ("id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("source_id") REFERENCES "reservations" ("id");

ALTER TABLE "authorization_token" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "reservations" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
