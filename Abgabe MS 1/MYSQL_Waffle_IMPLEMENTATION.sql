-- -----------------------------------------------------
-- Schema WaffleDB - Changed 25.05.2021 @ 17:00 - Lukas
-- -----------------------------------------------------

DROP DATABASE IF EXISTS `WaffleDB`;
CREATE DATABASE IF NOT EXISTS `WaffleDB`;
USE `WaffleDB` ;

-- -----------------------------------------------------
-- Table `NutritionalInformation`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `NutritionalInformation`;

CREATE TABLE IF NOT EXISTS `NutritionalInformation` 
(
  `idNuIn` INT NOT NULL,
  `calories` FLOAT NULL,
  `saturatedFat` FLOAT NULL,
  `transFat` FLOAT NULL,
  `carbohydrates` FLOAT NULL,
  `sugar` FLOAT NULL,
  `protein` FLOAT NULL,
  `salt` FLOAT NULL,
  PRIMARY KEY (`idNuIn`)
);

-- -----------------------------------------------------
-- Table `Product`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Product` ;

CREATE TABLE IF NOT EXISTS `Product` 
(
  `idProduct` INT NOT NULL,
  `idNuIn` INT NOT NULL,
  `price` FLOAT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`idProduct`),
  CONSTRAINT `fk_Product_NutritionalInformation1`
    FOREIGN KEY (`idNuIn`)
    REFERENCES `NutritionalInformation` (`idNuIn`)
);

CREATE INDEX `fk_Product_NutritionalInformation1_idx` ON `Product` (`idNuIn` ASC);

-- -----------------------------------------------------
-- Table `Addition`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Addition` ;

CREATE TABLE IF NOT EXISTS `Addition` 
(
  `idAddition` INT NOT NULL,
  `optComment` VARCHAR(255) NULL,
  PRIMARY KEY (`idAddition`),
  CONSTRAINT `fk_Addition_Product1`
    FOREIGN KEY (`idAddition`)
    REFERENCES `Product` (`idProduct`)
);

CREATE INDEX IF NOT EXISTS `fk_Addition_Product1_idx` ON `Addition` (`idAddition` ASC);

-- -----------------------------------------------------
-- Table `Ingredient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Ingredient` ;

CREATE TABLE IF NOT EXISTS `Ingredient` 
(
  `idIngredient` INT NOT NULL,
  `idNuIn` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `unit` VARCHAR(45) NOT NULL,
  `price` FLOAT NULL,
  `processingTimeSec` INT NOT NULL,
  PRIMARY KEY (`idIngredient`),
  CONSTRAINT `fk_Ingredient_NutritionalInformation1`
    FOREIGN KEY (`idNuIn`)
    REFERENCES `NutritionalInformation` (`idNuIn`)
);

CREATE INDEX `fk_Ingredient_NutritionalInformation1_idx` ON `Ingredient` (`idNuIn` ASC);


-- -----------------------------------------------------
-- Table `Store`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Store`;

CREATE TABLE IF NOT EXISTS `Store` 
(
  `idStore` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(255) NULL,
  `areaCode` VARCHAR(15) NULL,
  `location` VARCHAR(255) NULL,
  `streetName` VARCHAR(255) NULL,
  `houseNumber` VARCHAR(45) NULL
);

-- -----------------------------------------------------
-- Table `Inventory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Inventory` ;

CREATE TABLE IF NOT EXISTS `Inventory` 
(
  `idIngredient` INT NOT NULL,
  `idStore` INT NOT NULL,
  `expiryDate` DATE NULL,
  `deliveryDate` DATE NOT NULL,
  `amount` INT NOT NULL,
  PRIMARY KEY (`idIngredient`, `idStore`),
  CONSTRAINT `fk_Inventory_Ingredient`
    FOREIGN KEY (`idIngredient`)
    REFERENCES `Ingredient` (`idIngredient`),
  CONSTRAINT `fk_Inventory_StoreA`
    FOREIGN KEY (`idStore`)
    REFERENCES `Store` (`idStore`)
);

CREATE INDEX IF NOT EXISTS `fk_Inventory_StoreA_idx` ON `Inventory` (`idStore` ASC);

-- -----------------------------------------------------
-- Table `WaffleOrder`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `WaffleOrder`;

CREATE TABLE IF NOT EXISTS `WaffleOrder` 
(
  `idOrder` INT NOT NULL,
  `idStore` INT NOT NULL,
  `totalAmount` DOUBLE NULL,
  `paymentStatus` INT NOT NULL,
  `orderDate` DATE NOT NULL,
  PRIMARY KEY (`idOrder`),
  CONSTRAINT `fk_Order_StoreA`
    FOREIGN KEY (`idStore`)
    REFERENCES `Store` (`idStore`)
);

CREATE INDEX `fk_Order_StoreA_idx` ON `WaffleOrder` (`idStore` ASC);

-- -----------------------------------------------------
-- Table `ProductOrder`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ProductOrder`;

CREATE TABLE IF NOT EXISTS `ProductOrder` 
(
  `idOrder` INT NOT NULL,
  `idProduct` INT NOT NULL,
  `amount` INT NULL,
  PRIMARY KEY (`idOrder`, `idProduct`),
  CONSTRAINT `fk_ProductOrder_Order1`
    FOREIGN KEY (`idOrder`)
    REFERENCES `WaffleOrder` (`idOrder`),
  CONSTRAINT `fk_ProductOrder_Product1`
    FOREIGN KEY (`idProduct`)
    REFERENCES `Product` (`idProduct`)
);

CREATE INDEX `fk_ProductOrder_Order1_idx` ON `ProductOrder` (`idOrder` ASC);

CREATE INDEX `fk_ProductOrder_Product1_idx` ON `ProductOrder` (`idProduct` ASC);

-- -----------------------------------------------------
-- Table `Waffle`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Waffle`;

CREATE TABLE IF NOT EXISTS `Waffle` 
(
  `idWaffle` INT NOT NULL,
  `creatorName` VARCHAR(255) NULL,
  `creationDate` DATE NOT NULL,
  `processingTimeSec` INT NOT NULL,
  PRIMARY KEY (`idWaffle`),
  CONSTRAINT `fk_Waffle_Product1`
    FOREIGN KEY (`idWaffle`)
    REFERENCES `Product` (`idProduct`)
);

CREATE INDEX `fk_Waffle_Product1_idx` ON `Waffle` (`idWaffle` ASC);

-- -----------------------------------------------------
-- Table `WaffleIngredient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `WaffleIngredient`;

CREATE TABLE IF NOT EXISTS `WaffleIngredient` 
(
  `idIngredient` INT NOT NULL,
  `idWaffle` INT NOT NULL,
  `amount` INT NOT NULL,
  PRIMARY KEY (`idIngredient`, `idWaffle`),
  CONSTRAINT `fk_WaffleRecept_Ingredient1`
    FOREIGN KEY (`idIngredient`)
    REFERENCES `Ingredient` (`idIngredient`),
  CONSTRAINT `fk_WaffleRecept_Waffle1`
    FOREIGN KEY (`idWaffle`)
    REFERENCES `Waffle` (`idWaffle`)
);

CREATE INDEX `fk_WaffleRecept_Ingredient1_idx` ON `WaffleIngredient` (`idIngredient` ASC);

CREATE INDEX `fk_WaffleRecept_Waffle1_idx` ON `WaffleIngredient` (`idWaffle` ASC);












USE `WaffleDB` ;

-- -----------------------------------------------------
-- Placeholder table for view `WaffleConstruction`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `WaffleConstruction` (`name` INT, `price` INT, `amount` INT, `unit` INT);

-- -----------------------------------------------------
-- Placeholder table for view `IngredientOverview`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `IngredientOverview` (`name` INT, `sum(Inventory.amount)` INT, `unit` INT);

-- -----------------------------------------------------
-- View `WaffleConstruction`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `WaffleConstruction`;
DROP VIEW IF EXISTS `WaffleConstruction` ;
USE `WaffleDB`;
CREATE  OR REPLACE VIEW `WaffleConstruction` AS
SELECT Product.name as `ProductName`, Product.price, Ingredient.name as `IngredientName` ,WaffleIngredient.amount, Ingredient.unit FROM Product
Inner join Waffle on
	Waffle.idWaffle = Product.idProduct
Inner join WaffleIngredient on
	Waffle.idWaffle = WaffleIngredient.idWaffle
Inner join Ingredient on
	WaffleIngredient.idIngredient = Ingredient.idIngredient
order by Product.name
;

-- -----------------------------------------------------
-- View `IngredientOverview`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `IngredientOverview`;
DROP VIEW IF EXISTS `IngredientOverview` ;
USE `WaffleDB`;
CREATE  OR REPLACE VIEW `IngredientOverview` AS
select Ingredient.name as `IngredientName`, sum(Inventory.amount), Ingredient.unit, Store.name as `StoreName` from Ingredient
left join Inventory on
	Ingredient.idIngredient = Inventory.idIngredient
inner join Store on
	Store.idStore = Inventory.idStore
Where Inventory.expiryDate < curdate()
group by Inventory.idStore, Store.name
order by Ingredient.name;
