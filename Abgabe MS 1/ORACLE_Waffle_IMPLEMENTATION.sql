-- -----------------------------------------------------
-- DROP ANWEISUNG
-- -----------------------------------------------------

DROP TABLE Addition;
DROP TABLE Inventory;
DROP TABLE ProductOrder;
DROP TABLE WaffleOrder;
DROP TABLE WaffleStore;
DROP TABLE WaffleIngredient;
DROP TABLE Waffle;
DROP TABLE Ingredient;
DROP TABLE Product;
DROP TABLE NutritionalInformation;

DROP VIEW WaffleConstruction;
DROP VIEW IngredientOverview;


-- -----------------------------------------------------
-- Table NutritionalInformation
-- -----------------------------------------------------
CREATE TABLE NutritionalInformation (
  idNuIn INT NOT NULL PRIMARY KEY,
  calories FLOAT NULL,
  saturatedFat FLOAT NULL,
  transFat FLOAT NULL,
  carbohydrates FLOAT NULL,
  sugar FLOAT NULL,
  protein FLOAT NULL,
  salt FLOAT NULL
);

-- -----------------------------------------------------
-- Table Product
-- -----------------------------------------------------
CREATE TABLE Product (
  idProduct INT NOT NULL PRIMARY KEY,
  idNuIn INT NOT NULL,
  price FLOAT NOT NULL,
  name VARCHAR(255) NOT NULL,
  CONSTRAINT fk_Product_NutritionalInformation1
    FOREIGN KEY (idNuIn)
    REFERENCES NutritionalInformation (idNuIn)
);

CREATE INDEX fk_Product_NutritionalInformation1_idx ON Product (idNuIn ASC) VISIBLE;

-- -----------------------------------------------------
-- Table Addition
-- -----------------------------------------------------
CREATE TABLE Addition (
  idAddition INT NOT NULL PRIMARY KEY,
  optComment VARCHAR(255) NULL,
  CONSTRAINT fk_Addition_Product1
    FOREIGN KEY (idAddition)
    REFERENCES Product (idProduct)
);

-- -----------------------------------------------------
-- Table Ingredient
-- -----------------------------------------------------
CREATE TABLE Ingredient (
  idIngredient INT NOT NULL PRIMARY KEY,
  idNuIn INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  unit VARCHAR(45) NOT NULL,
  price FLOAT NULL,
  processingTimeSec INT NOT NULL,
  CONSTRAINT fk_Ingredient_NutritionalInformation1
    FOREIGN KEY (idNuIn)
    REFERENCES NutritionalInformation (idNuIn)
);

CREATE INDEX fk_Ingredient_NutritionalInformation1_idx ON Ingredient (idNuIn ASC) VISIBLE;

-- -----------------------------------------------------
-- Table Store
-- -----------------------------------------------------
CREATE TABLE WaffleStore (
  idStore INT NOT NULL PRIMARY KEY,
  name VARCHAR(255) NULL,
  areaCode VARCHAR(15) NULL,
  location VARCHAR(255) NULL,
  streetName VARCHAR(255) NULL,
  houseNumber VARCHAR(45) NULL
);

-- -----------------------------------------------------
-- Table Inventory
-- -----------------------------------------------------
CREATE TABLE Inventory (
  idIngredient INT NOT NULL,
  idStore INT NOT NULL,
  expiryDate DATE NULL,
  deliveryDate DATE NOT NULL,
  amount INT NOT NULL,
  CONSTRAINT fk_Inventory_Ingredient
    FOREIGN KEY (idIngredient)
    REFERENCES Ingredient (idIngredient),
  CONSTRAINT fk_Inventory_Store1
    FOREIGN KEY (idStore)
    REFERENCES WaffleStore (idStore),
  CONSTRAINT pk_Invetory
    PRIMARY KEY (idIngredient, idStore)
);

CREATE INDEX fk_Inventory_Store1_idx ON Inventory (idStore ASC) VISIBLE;

-- -----------------------------------------------------
-- Table Order
-- -----------------------------------------------------
CREATE TABLE WaffleOrder (
  idOrder INT NOT NULL PRIMARY KEY,
  idStore INT NOT NULL,
  totalAmount DOUBLE PRECISION NULL,
  paymentStatus INT NOT NULL,
  orderDate DATE NOT NULL,
  CONSTRAINT fk_Order_Store1
    FOREIGN KEY (idStore)
    REFERENCES WaffleStore (idStore)
);


CREATE INDEX fk_Waffle_Order_Store1_idx ON WaffleOrder (idStore ASC) VISIBLE;

-- -----------------------------------------------------
-- Table ProductOrder
-- -----------------------------------------------------
CREATE TABLE ProductOrder (
  idOrder INT NOT NULL,
  idProduct INT NOT NULL,
  amount INT NULL,
  CONSTRAINT fk_ProductOrder_Order1
    FOREIGN KEY (idOrder)
    REFERENCES WaffleOrder (idOrder),
  CONSTRAINT fk_ProductOrder_Product1
    FOREIGN KEY (idProduct)
    REFERENCES Product (idProduct),
  CONSTRAINT pk_ProductOrder
    PRIMARY KEY (idOrder, idProduct)
);

CREATE INDEX fk_ProductOrder_Order1_idx ON ProductOrder (idOrder ASC) VISIBLE;

CREATE INDEX fk_ProductOrder_Product1_idx ON ProductOrder (idProduct ASC) VISIBLE;

-- -----------------------------------------------------
-- Table Waffle
-- -----------------------------------------------------
CREATE TABLE Waffle (
  idWaffle INT NOT NULL PRIMARY KEY,
  creatorName VARCHAR(255) NULL,
  creationDate DATE NOT NULL,
  processingTimeSec INT NOT NULL,
  CONSTRAINT fk_Waffle_Product1
    FOREIGN KEY (idWaffle)
    REFERENCES Product (idProduct)
);

-- -----------------------------------------------------
-- Table WaffleIngredient
-- -----------------------------------------------------
CREATE TABLE WaffleIngredient (
  idIngredient INT NOT NULL,
  idWaffle INT NOT NULL,
  amount INT NOT NULL,
  CONSTRAINT fk_WaffleRecept_Ingredient1
    FOREIGN KEY (idIngredient)
    REFERENCES Ingredient (idIngredient),
  CONSTRAINT fk_WaffleRecept_Waffle1
    FOREIGN KEY (idWaffle)
    REFERENCES Waffle (idWaffle),
  CONSTRAINT pk_WaffleIngredient
    PRIMARY KEY (idIngredient, idWaffle)
);

CREATE INDEX fk_WaffleRecept_Ingredient1_idx ON WaffleIngredient (idIngredient ASC) VISIBLE;

CREATE INDEX fk_WaffleRecept_Waffle1_idx ON WaffleIngredient (idWaffle ASC) VISIBLE;

-- -----------------------------------------------------
-- View WaffleConstruction
-- -----------------------------------------------------
CREATE  OR REPLACE VIEW WaffleConstruction AS
SELECT Product.name as product_name, Product.price as price, Ingredient.name as ingredient_name ,WaffleIngredient.amount as amount, Ingredient.unit as unit FROM Product
Inner join Waffle on
	Waffle.idWaffle = Product.idProduct
Inner join WaffleIngredient on
	Waffle.idWaffle = WaffleIngredient.idWaffle
Inner join Ingredient on
	WaffleIngredient.idIngredient = Ingredient.idIngredient
order by Product.name
;

-- -----------------------------------------------------
-- View IngredientOverview
-- -----------------------------------------------------
CREATE OR REPLACE VIEW IngredientOverview AS
select Ingredient.name as ingredient_name, sum(Inventory.amount) as inventory_amount, Ingredient.unit as ingredient_unit, WaffleStore.name as wafflestore_name from Ingredient
left join Inventory on
	Ingredient.idIngredient = Inventory.idIngredient
inner join WaffleStore on
	WaffleStore.idStore = Inventory.idStore
Where Inventory.expiryDate < CURRENT_DATE
group by Inventory.idStore, WaffleStore.name, Ingredient.name, Ingredient.unit
order by Ingredient.name;








