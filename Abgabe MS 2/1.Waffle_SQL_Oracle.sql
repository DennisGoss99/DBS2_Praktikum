-- -----------------------------------------------------
-- KONFIGURATION ANWEISUNG				    
-- -----------------------------------------------------
SET SERVEROUTPUT ON;
ALTER SESSION SET nls_numeric_characters = '.,';

-- -----------------------------------------------------
-- DROP ANWEISUNG				    
-- -----------------------------------------------------
DROP TABLE Addition;
DROP TABLE Inventory;
DROP TABLE ProductOrder;
DROP TABLE WaffleOrder;
DROP TABLE PersonalNotification;
DROP TABLE WaffleStore;
DROP TABLE WaffleIngredient;
DROP TABLE Waffle;
DROP TABLE Ingredient;
DROP TABLE Product;
DROP TABLE NutritionalInformation;

DROP VIEW WaffleConstruction;
DROP VIEW IngredientOverview;
DROP VIEW PersonalNotificationView;

DROP TYPE waffle_t;
DROP TYPE addition_t;
DROP TYPE product_t;

-- -----------------------------------------------------
-- ADT Product
-- -----------------------------------------------------
CREATE OR REPLACE TYPE product_t AS OBJECT (
  idProduct INT,
  idNuIn INT,
  price FLOAT,
  name VARCHAR(255)
) NOT FINAL;
/

-- -----------------------------------------------------
-- ADT Waffle
-- -----------------------------------------------------
CREATE OR REPLACE TYPE waffle_t UNDER product_t (
  idWaffle INT,
  creatorName VARCHAR(255),
  creationDate DATE,
  processingTimeSec INT,
  healty VARCHAR(255)
)
/

-- -----------------------------------------------------
-- ADT Addition
-- -----------------------------------------------------
CREATE OR REPLACE TYPE addition_t UNDER product_t (
  idAddition INT,
  optComment VARCHAR(255)
)
/

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
CREATE TABLE Product OF product_t (
 idProduct PRIMARY KEY,
 idNuIn NOT NULL,
 price NOT NULL,
 name NOT NULL,
  CONSTRAINT fk_Product_NutritionalInformation1
    FOREIGN KEY (idNuIn)
    REFERENCES NutritionalInformation (idNuIn)
);

CREATE INDEX fk_Product_NutritionalInformation1_idx ON Product (idNuIn ASC) VISIBLE;

-- -----------------------------------------------------
-- Table Addition
-- -----------------------------------------------------
CREATE TABLE Addition OF addition_t (
  idAddition NOT NULL PRIMARY KEY
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
-- Table PersonalNotification
-- -----------------------------------------------------
CREATE TABLE PersonalNotification (
  idNotification INT NOT NULL PRIMARY KEY,
  idStore INT NOT NULL,
  message VARCHAR(255) NOT NULL,
  messageReason VARCHAR(255) NOT NULL,
  idIngredient INT NOT NULL,
  ingredientName VARCHAR(255) NOT NULL,
  time TIMESTAMP,
  CONSTRAINT fk_PersonalNotification_Store1
    FOREIGN KEY (idStore)
    REFERENCES PersonalNotification (idNotification)
);

-- -----------------------------------------------------
-- Table Inventory
-- -----------------------------------------------------
CREATE TABLE Inventory (
  idInventory INT NOT NULL,
  idIngredient INT NOT NULL,
  idStore INT NOT NULL,
  expiryDate DATE NULL,
  deliveryDate DATE NOT NULL,
  amount INT NOT NULL,
  isAccessible NUMBER NOT NULL,
  CONSTRAINT fk_Inventory_Ingredient
    FOREIGN KEY (idIngredient)
    REFERENCES Ingredient (idIngredient),
  CONSTRAINT fk_Inventory_Store1
    FOREIGN KEY (idStore)
    REFERENCES WaffleStore (idStore),
  CONSTRAINT pk_Inventory
    PRIMARY KEY (idInventory)
);

CREATE INDEX fk_Inventory_Store1_idx ON Inventory (idStore ASC) VISIBLE;

-- -----------------------------------------------------
-- Table WaffleOrder
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
  calculatedTime NUMBER,
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
CREATE TABLE Waffle OF waffle_t(
  idWaffle NOT NULL PRIMARY KEY,
  creationDate NOT NULL
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
CREATE OR REPLACE VIEW WaffleConstruction AS
	SELECT Waffle.name as product_name, Waffle.price as price, Ingredient.name as ingredient_name, WaffleIngredient.amount as amount, Ingredient.unit as unit FROM Waffle
	Inner join WaffleIngredient on Waffle.idWaffle = WaffleIngredient.idWaffle
	Inner join Ingredient on WaffleIngredient.idIngredient = Ingredient.idIngredient
	order by product_name;

-- -----------------------------------------------------
-- View IngredientOverview
-- -----------------------------------------------------
CREATE OR REPLACE VIEW IngredientOverview AS
	select Ingredient.name as ingredient_name, sum(Inventory.amount) as inventory_amount, Ingredient.unit as ingredient_unit, WaffleStore.name as wafflestore_name from Ingredient
	left join Inventory on Ingredient.idIngredient = Inventory.idIngredient
	inner join WaffleStore on WaffleStore.idStore = Inventory.idStore
	Where Inventory.expiryDate < CURRENT_DATE
	group by Inventory.idStore, WaffleStore.name, Ingredient.name, Ingredient.unit
	order by Ingredient.name;

-- -----------------------------------------------------
-- View PersonalNotificationView
-- -----------------------------------------------------
CREATE OR REPLACE VIEW PersonalNotificationView AS 
	SELECT * FROM PersonalNotification ORDER BY time DESC;

-- -----------------------------------------------------
-- INSERTS
-- -----------------------------------------------------
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (1, 300, 2, 2, 5, 10, 5, 1);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (2, 450, 5, 2, 5, 10, 5, 1);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (3, 500, 10, 10, 10, 10, 10, 10);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (4, 60, 0, 0, 0, 0, 0, 0);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (5, 350, 3, 3, 5, 5, 3, 1);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (6, 250, 3, 3, 5, 5, 3, 1);
    
INSERT INTO NutritionalInformation (idNuIn, calories, saturatedFat, transFat, carbohydrates, sugar, protein, salt)
    VALUES (7, 80, 3, 1, 3, 1, 3, 1);

INSERT INTO INGREDIENT (idIngredient, idNuIn, name, unit, price, processingTimeSec)
    VALUES (1, 1, 'Banane', 'g', 0.5, 3);
    
INSERT INTO INGREDIENT (idIngredient, idNuIn, name, unit, price, processingTimeSec)
    VALUES (2, 2, 'Schoko', 'g', 1, 3);
    
INSERT INTO INGREDIENT (idIngredient, idNuIn, name, unit, price, processingTimeSec)
    VALUES (3, 4, 'Apfel', 'g', 0.5, 3);
    
INSERT INTO INGREDIENT (idIngredient, idNuIn, name, unit, price, processingTimeSec)
    VALUES (4, 7, 'Teig', 'g', 0.2, 5);
    
INSERT INTO Product
    VALUES (product_t(4, 5, 3.5, 'ApfelWaffel'));
    
INSERT INTO Product
    VALUES (product_t(5, 6, 2, 'Waffel Ohne Alles'));

INSERT INTO Waffle 
    VALUES (waffle_t(1, 1, 10, 'BananenWaffel', 1, 'Gustav', to_date('30.12.2020', 'dd.MM.yyyy'), NULL, NULL));

INSERT INTO Waffle 
    VALUES (waffle_t(2, 2, 15, 'SchokoWaffel', 2, 'Gustav', to_date('30.12.2020', 'dd.MM.yyyy'), NULL, NULL));

INSERT INTO Waffle 
    VALUES (waffle_t(3, 3, 15, 'MegaSchokoWaffel', 3, 'Gustav', to_date('30.12.2020', 'dd.MM.yyyy'), NULL, NULL));
    
INSERT INTO Waffle
    VALUES (waffle_t(4, 5, 3.5, 'ApfelWaffel', 4, 'Berndt', to_date('31.12.2020', 'dd.MM.yyyy'), NULL, NULL));
    
INSERT INTO Waffle
    VALUES (waffle_t(5, 6, 2, 'Waffel Ohne Alles', 5, 'Berndt', to_date('31.12.2020', 'dd.MM.yyyy'), NULL, NULL));

INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (1, 1, 10);
    
INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (2, 2, 5);   
    
INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (3, 3, 5); 
    
INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (3, 4, 2); 
    
INSERT INTO WAFFLEINGREDIENT(idIngredient, idWaffle, amount)
    VALUES (4, 5, 1); 

INSERT INTO WaffleStore (idStore, name, areaCode, location, streetName, houseNumber)
    VALUES (1, 'Waffle GMBH', '58540', 'Meinerzhagen', 'Oststraße', '38');
    
INSERT INTO INVENTORY(idInventory, idIngredient, idStore, expiryDate, deliveryDate, amount, isAccessible)
    VALUES (1, 1, 1, to_date('30.01.3032', 'dd.MM.yyyy'), to_date('30.01.3030', 'dd.MM.yyyy'), 10, 1);   
    
INSERT INTO INVENTORY(idInventory, idIngredient, idStore, expiryDate, deliveryDate, amount, isAccessible)
    VALUES (2, 3, 1, to_date('30.01.3032', 'dd.MM.yyyy'), to_date('30.01.3030', 'dd.MM.yyyy'), 100, 1);  
    
INSERT INTO INVENTORY(idInventory, idIngredient, idStore, expiryDate, deliveryDate, amount, isAccessible)
    VALUES (3, 4, 1, to_date('30.01.3032', 'dd.MM.yyyy'), to_date('30.01.3030', 'dd.MM.yyyy'), 100, 1);  
    
INSERT INTO WaffleOrder(idOrder, idStore, totalAmount, paymentStatus, orderDate)
    VALUES (1, 1, 2, 0, to_date('30.12.2020', 'dd.MM.yyyy'));
    
INSERT INTO WaffleOrder(idOrder, idStore, totalAmount, paymentStatus, orderDate)
    VALUES (2, 1, 2, 0, to_date('30.12.2020', 'dd.MM.yyyy'));
    
/*
INSERT INTO PRODUCTORDER(idOrder, idProduct, amount, calculatedTime)
    VALUES (1, 4, 2, NULL);
*/

COMMIT;

-- -----------------------------------------------------
-- Prozeduren
-- -----------------------------------------------------

-- ---------------------------------------
-- Erste Prozedur: Benachrichtigen 	--
-- ---------------------------------------
Create or Replace PROCEDURE NotifyPersonal (s_reason IN VARCHAR2, s_ingredient IN NUMBER, s_store IN NUMBER) 
IS 
    v_message VARCHAR(255);
    v_name VARCHAR(255);
    v_Ingredient_name VARCHAR(255);
BEGIN
    SELECT w.name INTO v_name FROM WaffleStore w WHERE idStore = s_store;
    SELECT name INTO v_Ingredient_name FROM INGREDIENT i WHERE i.idingredient = s_ingredient;
    
    v_message := CASE s_reason
        WHEN 'niedrig' THEN 'Angestellte des Geschäfts ' || v_name ||'. Bitte '|| v_Ingredient_name ||' nachbestellen'
        WHEN 'abgelaufen' THEN 'Angestellte des Geschäfts ' || v_name ||'. Bitte ' ||''|| v_Ingredient_name ||' entsorgen'
        WHEN 'gesperrt' THEN 'Angestellte des Geschäfts ' || v_name || ', ' || v_Ingredient_name || ' ist bis auf weiteres gesperrt'
    END;
    
    INSERT INTO PersonalNotification (idNotification, idStore, message, messageReason, idIngredient, ingredientName, time)
        VALUES (NVL((SELECT MAX(idNotification) + 1 FROM PERSONALNOTIFICATION), 1), s_store, v_message, s_reason, s_ingredient, v_Ingredient_name, SYSDATE);
END;
/

-- ---------------------------------------
-- Zweite Prozedur: Lager aktualisieren
-- ---------------------------------------
CREATE OR REPLACE PROCEDURE InventoryUpdate 
(
    idStore INT,
    in_idIngredient INT,
    ingredientAmount IN INT,
    calcModeString IN VARCHAR, -- add or sub
    
    expiryDateOnInsert DATE,
    deliveryDateOnInsert DATE
)
IS
    v_hasIngreadient BOOLEAN;
    v_amountOfIngreadients INT;
    v_ingreadientsSearchResults INT;
    
    v_currentIngredientAmount INT;
    v_deleteID INT;
    v_deleteAmount INT;
    
    -- ErrorCodes -
    NotEnoghIngredientsExeption EXCEPTION;
    InvalidModeExeption EXCEPTION;
    NoIngredientWithThatNameExeption EXCEPTION;  
BEGIN     
    -- Check if this ingridient already exists --
    SELECT count(*) INTO v_ingreadientsSearchResults FROM INGREDIENT WHERE INGREDIENT.idIngredient = in_idIngredient;
    
    v_hasIngreadient := v_ingreadientsSearchResults > 0;
        
    -- Count ingredient Amount --
    SELECT sum(amount) INTO v_amountOfIngreadients
    FROM INVENTORY
    WHERE 
    (
        inventory.idingredient = in_idIngredient
        AND
        inventory.idstore = idStore   
        AND
        INVENTORY.expirydate >= Sysdate 
    ); 
    
    -- Select Mode --   
        IF  calcModeString like 'add' THEN      
            IF v_hasIngreadient THEN     
                -- Add new ingreadient --
                INSERT INTO INVENTORY 
                (
                    idInventory,
                    idIngredient,
                    idStore,
                    expirydate,                    
                    deliverydate, 
                    amount,
                    isaccessible
                )
    
                VALUES
                (
                    (select MAX(idInventory) from INVENTORY) +1,
                    in_idIngredient,
                    idStore,
                    expiryDateOnInsert,
                    deliveryDateOnInsert,
                    ingredientAmount,
                    1
                );             
            ELSE
                -- There is no Ingreadient, we can't add it--
                RAISE NoIngredientWithThatNameExeption;
            END IF; 
            
        ELSIF calcModeString like 'sub' THEN 
            IF v_hasIngreadient THEN
                IF v_amountOfIngreadients = ingredientAmount THEN
                    -- We take the same amount of what is left --
                    DELETE FROM INVENTORY                                   
                    WHERE 
                    (   
                        inventory.idingredient = in_idIngredient
                        AND
                        inventory.idstore = idStore
                    );     
                ELSIF ingredientAmount < ingredientAmount THEN
                    -- There are not enough. Throw exeption. --
                    RAISE NotEnoghIngredientsExeption;             
                ELSE                    
                    -- There are enogh the take. --    
                    v_currentIngredientAmount := ingredientAmount;
                    
                    WHILE v_currentIngredientAmount > 0
                    LOOP
                        
                        SELECT idinventory INTO v_deleteID FROM inventory
                        WHERE 
                        (
                            inventory.idingredient = in_idIngredient
                            AND
                            inventory.idstore = idStore   
                            AND
                            INVENTORY.expirydate >= CURRENT_TIMESTAMP
                        )
                        FETCH NEXT 1 ROWS ONLY;                    
                        
                        -- Get amount --
                        SELECT amount INTO v_deleteAmount FROM inventory
                        WHERE inventory.idinventory = v_deleteID;
                        
                        
                        IF v_deleteAmount > v_currentIngredientAmount THEN
                            -- Reduce amount --
                            UPDATE inventory SET amount = v_deleteAmount - v_currentIngredientAmount
                            WHERE inventory.idinventory = v_deleteID;
                        ELSE
                            Delete from inventory 
                            WHERE inventory.idinventory = v_deleteID;
                        END IF;
                        
                        -- Reduce --
                        v_currentIngredientAmount := v_currentIngredientAmount - v_deleteAmount;                        
                    END LOOP;                                   
                END IF;                
            ELSE
                -- ERROR - ingredient does not exist!
                RAISE NoIngredientWithThatNameExeption;   
            END IF;            
        ELSE    
            RAISE InvalidModeExeption;
     END IF;        
END;
/

-- ---------------------------------------
-- Dritte Prozedur: Lager aktualisieren und Ingredient hinzufügen
-- ---------------------------------------
CREATE OR REPLACE PROCEDURE OnInventoryAdd (
    s_idProduct IN INT,
    s_idOrder IN INT,
    s_extenal_amount IN INT
)
IS
    v_store INT;
    v_waffle_id INT;
    
    v_cursor_ingredientid INT;
    v_cursor_amount INT;
    
    v_cursor_expiryDate DATE;
    v_cursor_deliveryDate DATE;
    
    v_operator VARCHAR(3) := 'add';
    
    CURSOR v_Ingredient_Cursor_On_Insert(w_Id INT) IS
        SELECT idIngredient, amount FROM WAFFLEINGREDIENT WHERE idWaffle = w_Id;
        
    CURSOR v_Ingredient_Cursor_On_Delete(i_id INT) IS
        SELECT expiryDate, deliveryDate FROM Inventory WHERE idIngredient = i_id;
BEGIN
    SELECT idStore INTO v_store FROM WAFFLEORDER WHERE idOrder = s_idOrder;
    SELECT w.idWaffle INTO v_waffle_id FROM Waffle w WHERE w.idProduct = s_idProduct;
    
    -- Wenn z.B mehr als eine Waffel bestellt wurde, dann muss die Prozedur 1..x mal aufgerufen werden
    FOR x IN 1..s_extenal_amount LOOP
        -- Hole alle Ingredient Informationen der Waffel
        OPEN v_Ingredient_Cursor_On_Insert(v_waffle_id);
        LOOP
             FETCH v_Ingredient_Cursor_On_Insert INTO v_cursor_ingredientId, v_cursor_amount;
             EXIT WHEN v_Ingredient_Cursor_On_Insert%NOTFOUND;
             
             -- Hole alle alten Einlieferungsdatum und Ablaufdatum des Ingredient
             OPEN v_Ingredient_Cursor_On_Delete(v_cursor_ingredientId);
             LOOP
                 FETCH v_Ingredient_Cursor_On_Delete INTO v_cursor_expiryDate, v_cursor_deliveryDate;
                 EXIT WHEN v_Ingredient_Cursor_On_Delete%NOTFOUND;
             END LOOP;
             CLOSE v_Ingredient_Cursor_On_Delete;
        END LOOP;
        CLOSE v_Ingredient_Cursor_On_Insert;
        
    -- Aktualisiere jetzt nach den abgeholten Daten das Lager
    InventoryUpdate(v_store, v_cursor_ingredientId, v_cursor_amount, v_operator, v_cursor_expiryDate, v_cursor_deliveryDate);
    END LOOP;
END;
/

-- ---------------------------------------
-- Vierte Prozedur: Lager aktualisieren und Ingredient rausnehmen
-- ---------------------------------------
CREATE OR REPLACE PROCEDURE OnInventoryDelete (
    s_idProduct IN INT,
    s_idOrder IN INT,
    s_extenal_amount IN INT
)
IS
    v_store INT;
    v_waffleid INT;
    
    v_cursor_ingredientId INT;
    v_cursor_amount INT;
    
    v_operator VARCHAR(3) := 'sub';
    
    CURSOR v_Ingredient_Cursor_On_Insert(w_Id INT) IS
        SELECT idIngredient, amount FROM WAFFLEINGREDIENT WHERE idWaffle = w_Id;
BEGIN
    SELECT idStore INTO v_store FROM WaffleOrder WHERE idOrder = s_idOrder;
    SELECT w.idWaffle INTO v_waffleid FROM Waffle w WHERE w.idProduct = s_idProduct;
    
    FOR x in 1..s_extenal_amount LOOP
        OPEN v_Ingredient_Cursor_On_Insert(v_waffleid);
        LOOP
             FETCH v_Ingredient_Cursor_On_Insert INTO v_cursor_ingredientId, v_cursor_amount;
             EXIT WHEN v_Ingredient_Cursor_On_Insert%NOTFOUND;
             
             InventoryUpdate(v_store, v_cursor_ingredientId, v_cursor_amount, v_operator, NULL, NULL);  
        END LOOP;
        CLOSE v_Ingredient_Cursor_On_Insert;
    END LOOP;
END;
/

-- -----------------------------------------------------
-- Funktionen
-- -----------------------------------------------------

-- ---------------------------------------
-- Erste Funktion: Preiswertrechner 	--
-- ---------------------------------------
CREATE OR REPLACE FUNCTION GrossNetCalculator (bruttoPreis IN NUMBER, mwst IN NUMBER DEFAULT 0.19)
    RETURN NUMBER
    IS
        Ergebnis NUMBER;
    BEGIN
        Ergebnis := bruttoPreis * (1 + mwst);
        RETURN ROUND(Ergebnis, 2);
    END;
/

-- ---------------------------------------
-- Zweite Funktion: Nährwertrechner 	--
-- ---------------------------------------
CREATE OR REPLACE FUNCTION NutritionCalculator (in_idNui IN INT, healtyCalories IN NUMBER DEFAULT 350, healtySugar IN NUMBER DEFAULT 10)
    RETURN VARCHAR
    IS
        v_calories FLOAT NULL;
        v_saturatedFat FLOAT NULL;
        v_transFat FLOAT NULL;
        v_carbohydrates FLOAT NULL;
        v_sugar FLOAT NULL;
        v_protein FLOAT NULL;
        v_salt FLOAT NULL;
        Ergebnis VARCHAR2(64);
    BEGIN
        SELECT CALORIES, SATURATEDFAT, TRANSFAT, CARBOHYDRATES, SUGAR, PROTEIN, SALT 
        INTO  v_calories, v_saturatedFat, v_transFat, v_carbohydrates, v_sugar, v_protein, v_salt 
        FROM NutritionalInformation WHERE idNuIn = in_idNui;
        
        IF v_calories > healtyCalories OR v_sugar > healtySugar THEN
            IF v_transFat > 3 OR v_saturatedFat > 15 OR v_salt > 10 THEN
                Ergebnis := 'Ungesund';
            ELSE
                Ergebnis := 'Mäßig Gesund';
            END IF;
        ELSE
            Ergebnis := 'Gesund';
        END IF;
        
        Return Ergebnis;
    END;
/

-- ---------------------------------------
-- Dritte Funktion: Bestellzeitaufwand 	--
-- ---------------------------------------
CREATE OR REPLACE FUNCTION OrderTimeCalculator (in_idwaffle IN INT)
RETURN INT
IS
 i_waffletime_in_s INT := 0;
BEGIN
    SELECT SUM(ing.processingTimeSec * wi.amount) INTO i_waffletime_in_s FROM WaffleIngredient wi, Ingredient ing
    WHERE wi.idWaffle = in_idwaffle AND ing.idIngredient = wi.idIngredient;

    RETURN i_waffletime_in_s;
END;
/

-- -----------------------------------------------------
-- Trigger
-- -----------------------------------------------------

-- ---------------------------------------
-- Erster Trigger: Bestandsänderung 	--
-- ---------------------------------------
CREATE OR REPLACE TRIGGER OnInventoryUpdate
    BEFORE UPDATE ON INVENTORY
    FOR EACH ROW
    WHEN (New.Amount <> Old.Amount)
    DECLARE
        id NUMBER(1) := :New.idIngredient;
        store NUMBER(1) := :New.idStore;
    BEGIN
        IF :New.amount < 2 THEN
            :new.isAccessible := 0;
            NotifyPersonal('gesperrt', id, store);
        ELSIF :New.amount < 5 THEN
            NotifyPersonal('niedrig', id, store);
        ELSIF :New.amount > 5 THEN
            :new.isAccessible := 0;
        END IF;
    END;
/

-- ---------------------------------------
-- Zweiter Trigger: Bestellung erhalten --
-- ---------------------------------------
CREATE OR REPLACE TRIGGER OnProductOrder
BEFORE INSERT OR UPDATE OR DELETE ON PRODUCTORDER
FOR EACH ROW
DECLARE
    v_processingTime INT;
    v_amount_difference INT;
BEGIN
    IF INSERTING THEN
        SELECT w.processingTimeSec INTO v_processingTime FROM Waffle w WHERE w.idProduct = :New.idProduct;
        :New.CalculatedTime := :New.Amount * NVL(v_processingTime, 100);
        
        OnInventoryDelete(:New.idProduct, :New.idOrder, :New.Amount);
    END IF;
    
    IF UPDATING THEN
        v_amount_difference := :Old.Amount - :New.Amount;
            
        -- Wenn v_amount_difference < 0 ist, bedeutet das -> :New.Amount > :Old.Amount. 
        -- Wir müssen also wieder Ingredient aus dem Inventar nehmen
        IF v_amount_difference < 0 THEN
            OnInventoryDelete(:Old.idProduct, :Old.idOrder, ABS(v_amount_difference));
                
        -- Wenn v_amount_difference > 0 ist, bedeutet das -> :New.Amount < :Old.Amount.
        -- Wir müssen also wieder Ingredient dem Inventar hinzufügen
        ELSIF v_amount_difference > 0 THEN
            OnInventoryAdd(:Old.idProduct, :Old.idOrder, v_amount_difference);
        END IF;
    END IF;
    
    IF DELETING THEN
        OnInventoryAdd(:Old.idProduct, :Old.idOrder, :Old.Amount);
    END IF;
END;
/

-- ---------------------------------------
-- Dritter Trigger: Bestellung abges.   --
-- ---------------------------------------
CREATE OR REPLACE TRIGGER OnFinishOrder
BEFORE UPDATE ON waffleorder
FOR EACH ROW
WHEN (NEW.paymentstatus = 1)
DECLARE
    v1 int;
    v_id_product INT;
BEGIN  
        SELECT SUM(product.price * productorder.amount ) INTO v1
        from productorder
        RIGHT join product on productorder.idproduct = product.idproduct
            WHERE IDORDER = :NEW.idOrder
            GROUP BY productorder.idorder;
    
    :NEW.totalamount := v1;

END finish_Ordner;
/

-- ---------------------------------------
-- Vierter Trigger: Lebensmittel abgel. --
-- ---------------------------------------
CREATE OR REPLACE TRIGGER OnInventoryUpdate
    BEFORE INSERT OR UPDATE ON Inventory
    FOR EACH ROW 
DECLARE
	id NUMBER(1) := :new.idIngredient;
	store NUMBER(1) := :new.idStore;
BEGIN 
    IF :new.expirydate < Sysdate THEN
        NotifyPersonal('abgelaufen', id, store);
    END IF;
    
END;
/

-- ---------------------------------------
-- Fünfter Trigger: Zutat hinzug. / Update
-- ---------------------------------------
CREATE OR REPLACE TRIGGER IngredientChanged
AFTER UPDATE ON INGREDIENT 
for each row 
DECLARE
    v_oldPrice FLOAT;
    v_newPrice FLOAT;

    v_CursorID INT;
    v_CursorAmount INT;

    CURSOR v_waffleToChange(in_idIngredient INT) IS
        SELECT idWaffle, amount 
        FROM waffleingredient
        WHERE idingredient = in_idIngredient;
BEGIN
    OPEN v_waffleToChange(:NEW.idIngredient);
    LOOP
    FETCH v_waffleToChange INTO v_CursorID, v_CursorAmount;
    EXIT WHEN v_waffleToChange%NOTFOUND;

    v_oldPrice := :OLD.price * v_CursorAmount;
    v_newPrice := :NEW.price * v_CursorAmount;

    UPDATE PRODUCT 
    SET price = (price - v_oldPrice) + v_newPrice
    where idproduct = v_CursorID;
    
    UPDATE WAFFLE 
    SET price = (price - v_oldPrice) + v_newPrice
    where idWaffle = v_CursorID;

    END LOOP;
END;
/

-- ---------------------------------------
-- Sechster Trigger: Waffel hinzug. / Update
-- ---------------------------------------
CREATE OR REPLACE TRIGGER OnWaffleInsertOrUpdate
BEFORE INSERT OR UPDATE ON WAFFLE
FOR EACH ROW
BEGIN
    :New.creationDate := SYSDATE;
    :New.processingTimeSec := NVL(OrderTimeCalculator(:New.idWaffle), 100);
    :New.healty := NVL(NutritionCalculator(:New.idNuIn), 'Mäßig Gesund');
END;
/

-- ---------------------------------------
-- Instead of Trigger: WaffleConstruction
-- ---------------------------------------
CREATE OR REPLACE TRIGGER OnWaffleConstructionInsertOrUpdate
    INSTEAD OF UPDATE ON WaffleConstruction
    FOR EACH ROW
    BEGIN
        UPDATE WAFFLE w SET w.name = :new.product_name
        WHERE name = :old.product_name;
        
        UPDATE WAFFLE w SET w.price = :new.price
        WHERE price = :old.price;
        
        UPDATE INGREDIENT i SET i.name = :new.ingredient_name
        WHERE name = :old.ingredient_name;
         
        UPDATE WaffleIngredient SET amount = :new.amount
        WHERE amount = :old.amount;
        
        UPDATE INGREDIENT SET unit = :new.unit
        WHERE unit = :old.unit;
    END;
/

COMMIT;