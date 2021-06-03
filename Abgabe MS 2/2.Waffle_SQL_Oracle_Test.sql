-- -----------------------------------------------------
-- KONFIGURATION ANWEISUNG				    
-- -----------------------------------------------------
SET SERVEROUTPUT ON;
ALTER SESSION SET nls_numeric_characters = '.,';

-- -----------------------------------------------------
-- DROP ANWEISUNG				    
-- -----------------------------------------------------
DROP PROCEDURE NotifyPersonal;
DROP PROCEDURE InventoryUpdate;
DROP PROCEDURE OnInventoryAdd;
DROP PROCEDURE OnInventoryDelete;

DROP FUNCTION GrossNetCalculator;
DROP FUNCTION NutritionCalculator;
DROP FUNCTION OrderTimeCalculator;

DROP TRIGGER OnInventoryUpdate;
DROP TRIGGER OnProductOrder;
DROP TRIGGER OnFinishOrder;
DROP TRIGGER IngredientChanged;
DROP TRIGGER OnInventoryUpdate;
DROP TRIGGER OnWaffleInsertOrUpdate;
DROP TRIGGER OnWaffleConstructionInsertOrUpdate;


-- -----------------------------------------------------
-- Prozeduren
-- -----------------------------------------------------

-- ---------------------------------------
-- Erste Prozedur: Benachrichtigen (1) 	--

-- input: 
--	s_reason -> Grund der Nachricht
--	s_ingredient -> Ingredient id
--	s_store -> Store id

-- Prozedur nimmt den Grund der Nachricht, baut daraus eine Message zusammen und schreibt zusätzlich in die Message
-- noch den Ingredient Namen und den Store Namen. Mit dieser Prozedur kann das Personal sehen, wenn es ein Problem
-- in der Datenbank gibt
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

-- -------------------------------
-- Test 1 zur Prozedur 1	--
-- -------------------------------
CALL NotifyPersonal('niedrig', 1, 1);

SELECT * FROM PersonalNotification;
-- -------------------------------
-- Endergebnis: Insert in der Tabelle PersonalNotification mit den Daten "1, 1, 
-- Angestellte des [...], "niedrig" 1, Banane"
-- -------------------------------

-- -------------------------------
-- Test 2 zur Prozedur 1	--
-- -------------------------------
CALL NotifyPersonal('abgelaufen', 1, 1);

SELECT * FROM PersonalNotification;
-- -------------------------------
-- Endergebnis: Insert in der Tabelle PersonalNotification mit den Daten "2, 1, 
-- Angestellte des [...], "abgelaufen" 1, Banane"
-- -------------------------------

-- ---------------------------------------
-- Zweite Prozedur: Lager aktualisieren (2)

-- input: 
--	idStore -> Store id
--	in_idIngredient -> Ingredient id
--	ingredientAmount -> Anzahl der Ingredient, die entnommen / hinzugefügt werden soll
--	calcModeString -> Operator
--	expiryDateOnInsert -> Expiry Datum des vergangegen lebensmittels
--	deliveryDateOnInsert -> Delivery Datum des vergangegen Lebensmittels

-- Diese Prozedur managet das Lager, indem entweder Zutaten dem Lager entnommen werden können 
-- (calcModeString = 'sub') oder Zutaten dem Lager hinzugefügt werden (calcModeString = 'add')
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


-- -------------------------------
-- Test 1 zur Prozedur 2	--
-- -------------------------------
SELECT amount FROM INVENTORY WHERE idIngredient = 3;

CALL InventoryUpdate(1, 3, 1, 'sub', NULL, NULL);

SELECT amount FROM INVENTORY WHERE idIngredient = 3;
-- -------------------------------
-- Endergebnis: Aus der Amount "100" wird "99"
-- Die Prozedur hat dem Lager mit der IdIngredient "3", "1" amount entnommen
-- -------------------------------


-- -------------------------------
-- Test 2 zur Prozedur 2	--
-- -------------------------------
SELECT * FROM INVENTORY;

CALL InventoryUpdate(1, 3, 1, 'add', to_date('30.01.2025'), to_date('30.01.2026'));

SELECT * FROM INVENTORY;
-- -------------------------------
-- Endergebnis: Es wurde ein neuer Datensatz im Inventory hinzugefügt:
-- Datensatz -> "4, 3, 1, 30.01.25, 30.01.26, 1, 1"
-- -------------------------------


-- ---------------------------------------
-- Dritte Prozedur: Lager aktualisieren und Ingredient hinzufügen (3)

-- input: 
--	s_idProduct -> Productid
--	s_idOrder -> Order id
--	s_extenal_amount -> Anzahl der schleifendurchläufe

-- Diese Prozedur holt alle IngredientInformationen der Waffel mit der oben angegebenen "ProductId"
-- entnimmt dann mit diesen Informationen zusätzlich noch die zuvor gespeicherten deliveryDatum und
-- expiryDatum und fügt dann dem Inventory die Ingredients der gefundenen Waffel wieder hinzu.
-- Dabei wird auf die Prozedur "InventoryUpdate" zugegriffen.
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

-- -------------------------------
-- Test 1 zur Prozedur 3	--
-- -------------------------------
SELECT * FROM INVENTORY;

SELECT * FROM WAFFLEINGREDIENT WHERE idWaffle = 4;

SELECT * FROM INGREDIENT WHERE idIngredient = 3;

CALL OnInventoryAdd(4, 1, 2);

SELECT * FROM INVENTORY;
-- -------------------------------
-- Endergebnis: Es wurden zwei neue Datensätze mit den Ingredients vom Product mit der Id "4", 
-- dem Inventory hinzugefügt. Das Product "4" hat zwei Amounts von der IdIngredient = 3

-- Datensatz -> "5, 3, 1, 30.01.25, 30.01.26, 2, 1"
-- Datensatz -> "6, 3, 1, 30.01.25, 30.01.26, 2, 1"
-- -------------------------------

-- -------------------------------
-- Test 2 zur Prozedur 3	--
-- -------------------------------
SELECT * FROM INVENTORY;

SELECT * FROM WAFFLEINGREDIENT WHERE idWaffle = 5;

SELECT * FROM INGREDIENT WHERE idIngredient = 4;

CALL OnInventoryAdd(5, 1, 1);

SELECT * FROM INVENTORY;
-- -------------------------------
-- Endergebnis: Es wurde ein neuer Datensätze mit den Ingredients vom Product mit der Id "5", 
-- dem Inventory hinzugefügt. Das Product "5" hat ein Amount von der IdIngredient = 4

-- Datensatz -> "7, 4, 1, 30.01.32, 30.01.30, 1, 1"
-- -------------------------------

-- ---------------------------------------
-- Vierte Prozedur: Lager aktualisieren und Ingredient rausnehmen (4)

-- input: 
--	s_idProduct -> Productid
--	s_idOrder -> Order id
--	s_extenal_amount -> Anzahl der schleifendurchläufe

-- Diese Prozedur holt alle IngredientInformationen der Waffel mit der oben angegebenen "ProductId"
-- und fügt diese dann dem Inventar wieder hinzu. Die Prozedur wird dabei "s_external_amount"-times wiederholt.
-- Dabei wird auf die Prozedur "InventoryUpdate" zugegriffen.
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

-- -------------------------------
-- Test 1 zur Prozedur 3	--
-- -------------------------------
SELECT amount FROM INVENTORY WHERE idInventory = 2; -- 99

CALL OnInventoryDelete(4, 1, 1);

SELECT amount FROM INVENTORY WHERE idInventory = 2; -- amount wurde um 2 verringert (97)
-- -------------------------------
-- Endergebnis: Der amount vom Inventar mit der idInventory = 2 wurde um 2 amounts verringert.
-- Wenn also z.B. vorher 99 Ingredients im Lager waren, sind es jetzt nurnoch 97.
-- -------------------------------

-- -------------------------------
-- Test 2 zur Prozedur 3	--
-- -------------------------------
SELECT amount FROM INVENTORY WHERE idInventory = 3; -- 97

CALL OnInventoryDelete(4, 1, 2); -- Jetzt wird das ganze mehrmals ausgefügt, da "s_external_amount " = 2

SELECT amount FROM INVENTORY WHERE idInventory = 3; -- amount wurde um 2 verringert (93)
-- -------------------------------
-- Endergebnis: Der amount vom Inventar mit der idInventory = 3 wurde um 4 amounts verringert.
-- Wenn also z.B. vorher 97 Ingredients im Lager waren, sind es jetzt nurnoch 93.
-- Die Prozedur wurde also zwei mal ausgefügt.
-- -------------------------------


-- -----------------------------------------------------
-- Funktionen
-- -----------------------------------------------------

-- ---------------------------------------
-- Erste Funktion: Preiswertrechner (3) 

-- input:
--	- bruttoPreis: BruttoPreis aus der Datenbank
--	- mwst: Mehrwertsteuer, optionaler Wert. Default = 0.19 (Deutschland)

-- Funktion berechnet den nettoPreis einer Waffel, damit dieser Preis
-- später der WaffleOrder zugeordnet werden kann
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

-- -------------------------------
-- Test 1 zur Funktion 1	--
-- -------------------------------

DECLARE
    v_bruttoPreis NUMBER;
BEGIN
    v_bruttoPreis := GrossNetCalculator(120);
    DBMS_OUTPUT.PUT_LINE(v_bruttoPreis);
END;
/
-- -------------------------------
-- Endergebnis: Ausgabe 148.2
-- -------------------------------

-- -------------------------------
-- Test 2 zur Funktion 1	--
-- -------------------------------

DECLARE
    v_bruttoPreisSchweiz NUMBER;
BEGIN
    v_bruttoPreisSchweiz := GrossNetCalculator(120, 0.077);
    DBMS_OUTPUT.PUT_LINE(v_bruttoPreisSchweiz);
END;
/
-- -------------------------------
-- Endergebnis: Ausgabe 129.24	
-- -------------------------------


-- ---------------------------------------
-- Zweite Funktion: Nährwertrechner (2)

-- input:
	-- in_idNui: NutritionId
	-- healtyCalories: Anzahl der noch als Gesund zählbaren Kalorien
	-- healtySugar: Anzahl der als noch Gesund zählbaren Zuckeranteils

-- Funktion berechnet, wie Gesund eine Waffel in der Datenbank ist.
-- Mit dieser Funktion kann (kranken) Kunden geholfen werden, eine Nachhaltig entscheidung zu treffen.
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

-- -------------------------------
-- Test 1 zur Funktion 2	--
-- -------------------------------
SELECT * FROM WAFFLE WHERE idNUIN = 1;
SELECT * FROM NUTRITIONALINFORMATION WHERE idNUIN = 1;

DECLARE
    v_gesund VARCHAR2(64);
BEGIN
    v_gesund := NutritionCalculator(1); -- Bananenwaffel
    DBMS_OUTPUT.PUT_LINE(v_gesund);
END;
/
-- -------------------------------
-- Endergebnis: Ausgabe Gesund		
-- -------------------------------

-- -------------------------------
-- Test 2 zur Funktion 2	--
-- -------------------------------
SELECT * FROM WAFFLE WHERE idNUIN = 2;
SELECT * FROM NUTRITIONALINFORMATION WHERE idNUIN = 2;

DECLARE
    v_mittelmäßig VARCHAR2(64);
BEGIN
    v_mittelmäßig := NutritionCalculator(2); -- Schokowaffel
    DBMS_OUTPUT.PUT_LINE(v_mittelmäßig);
END;
/
-- -------------------------------
-- Endergebnis: Ausgabe Mäßig Gesund	
-- -------------------------------

-- -------------------------------
-- Test 3 zur Funktion 2	--
-- -------------------------------
SELECT * FROM WAFFLE WHERE idNUIN = 3;
SELECT * FROM NUTRITIONALINFORMATION WHERE idNUIN = 3;

DECLARE
    v_ungesund VARCHAR2(64);
BEGIN
    v_ungesund := NutritionCalculator(3); --  Megaschokowaffel
    DBMS_OUTPUT.PUT_LINE(v_ungesund);
END;
/
-- -------------------------------
-- Endergebnis: Ausgabe Ungesund	
-- -------------------------------

-- ---------------------------------------
-- Dritte Funktion: Bestellzeitaufwand (3)

-- input:
	-- in_idWaffle: Waffle Id

-- Funktion summiert die Anzahl der Amounts in der WaffleIngredient mit der ProzessingTime in der Ingredient.
-- Wenn eine Waffel z.B zwei mal einen Apfel braucht und jeder Apfel eine dauer von 10 sekunden zur zubereitung
-- braucht, dann hat die Waffel eine Bestellzeit von 20 sekunden.
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


-- -------------------------------
-- Test 1 zur Funktion 3	--
-- -------------------------------

DECLARE
    v_time_1 INT;
BEGIN
    v_time_1 := OrderTimeCalculator(1); 
    DBMS_OUTPUT.PUT_LINE(v_time_1);
END;
/
-- -------------------------------
-- Endergebnis: 30 (sekunden)	
-- -------------------------------


-- -------------------------------
-- Test 2 zur Funktion 3	--
-- -------------------------------

DECLARE
    v_time_2 INT;
BEGIN
    v_time_2 := OrderTimeCalculator(2); 
    DBMS_OUTPUT.PUT_LINE(v_time_2);
END;
/
-- -------------------------------
-- Endergebnis: 15 (sekunden)	
-- -------------------------------


-- -----------------------------------------------------
-- Trigger
-- -----------------------------------------------------



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


-- -------------------------------
-- Test 1 zum Trigger 1		--
-- -------------------------------
SELECT * FROM INVENTORY;

UPDATE INVENTORY
    SET amount = 4 WHERE idInventory = 1;
    
SELECT * FROM PERSONALNOTIFICATION;
-- -------------------------------
-- Endergebnis: Neuer Datensatz in der Tabelle "PersonalNotification"

-- Datensatz -> "3, 1, Angestellte des [...], niedrig, 1, Banane"	
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 1		--
-- -------------------------------
SELECT * FROM INVENTORY;

UPDATE INVENTORY
    SET amount = 1 WHERE idInventory = 1;
    
SELECT * FROM PERSONALNOTIFICATION;

SELECT isAccessible FROM INVENTORY WHERE idInventory = 1;
-- -------------------------------
-- Endergebnis: Neuer Datensatz in der Tabelle "PersonalNotification"
-- Außerdem ist das Inventar mit der Id "1" gesperrt

-- Datensatz -> "3, 1, Angestellte des [...], gesperrt, 1, Banane"	
-- -------------------------------


-- ---------------------------------------
-- Zweiter Trigger: Bestellung erhalten (2)

-- Trigger hat drei verschiedene Aufgaben je nach DML anweisung:

-- Insert: Bestellzeit wird berechnet und die benötigten Ingredient der Waffel werden
-- aus dem Lager entfernt

-- Update: Wenn der Kunde eine Waffel mehr bestellt, wird die Ingredient wieder dem
-- Inventar hinzugefügt. Bestellt der Kunde eine Waffel ab (z.B Amount von 2 auf 1)
-- wird dem Inventar wieder die Ingredients der Waffel hinzugefügt

-- Delete: Storniert der Kunde eine Waffel, werden die dafür benötigten Ingredient
-- wieder dem Invetar hinzgefügt.
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

-- -------------------------------
-- Test 1 zum Trigger 2		--
-- -------------------------------
SELECT amount FROM INVENTORY WHERE idInventory = 2;

SELECT * FROM PRODUCTORDER;

DELETE FROM PRODUCTORDER;

INSERT INTO PRODUCTORDER(idOrder, idProduct, amount, calculatedTime)
    VALUES (1, 4, 2, NULL);

SELECT amount FROM INVENTORY WHERE idInventory = 2;
-- -------------------------------
-- Endergebnis: Amount der idInventory wurde um 4 verringert, da 2 Waffeln bestellt wurden, 
-- die jeweils 2 mal eine bestimmte Ingredient brauchen
-- -------------------------------


-- -------------------------------
-- Test 2 zum Trigger 2		--
-- -------------------------------
UPDATE PRODUCTORDER
    SET amount = 3;

SELECT amount FROM INVENTORY WHERE idInventory = 2;
-- -------------------------------
-- Endergebnis: Amount der idInventory wurde um 2 verringert, da 1 zusätzliche Waffeln bestellt wurde, 
-- die jeweils 2 mal eine bestimmte Ingredient braucht
-- -------------------------------

-- -------------------------------
-- Test 3 zum Trigger 2		--
-- -------------------------------
DELETE FROM PRODUCTORDER;

SELECT * FROM INVENTORY;
-- -------------------------------
-- Endergebnis: Dem Inventory wurden alle vorher benutzen Ingredient der zuvor bestellten Waffeln
-- wieder gut geschrieben
-- -------------------------------


-- ---------------------------------------
-- Dritter Trigger: Bestellung abges.   (3)

-- Wenn die Bestellung abgeschlossen wurde, soll die SchlussRechnung bestimmt werden.
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


-- -------------------------------
-- Vorbedingung zum Test	--
-- -------------------------------
UPDATE waffleorder
	SET paymentstatus = 0, totalamount = NULL;

DELETE FROM PRODUCTORDER;

INSERT INTO PRODUCTORDER(idOrder, idProduct, amount, calculatedTime)
    VALUES (1, 4, 2, NULL);

-- -------------------------------
-- Test 1 zum Trigger 3		--
-- -------------------------------
UPDATE waffleorder
	SET paymentstatus = 1 WHERE idOrder = 1;
		
Select * from waffleorder;
-- -------------------------------
-- Endergebnis: Totalamount wurde berechnet
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 3		--
-- -------------------------------
UPDATE waffleorder
  SET paymentstatus = 2 WHERE idorder = 1;
		
Select * from  waffleorder;
-- -------------------------------
-- Endergebnis: Zahlung ist abgeschlossen
-- -------------------------------


-- ---------------------------------------
-- Vierter Trigger: Lebensmittel abgel. (4)

-- Trigger der feuert, wenn es ein Update auf Inventory gibt. 
-- Prüft ob die geupdatete Zutat schon abgelaufen ist und falls sie es ist führt er die Prozedur benachrichtigen aus.
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

-- -------------------------------
-- Test 1 zum Trigger 4		--
-- -------------------------------
SELECT * FROM INVENTORY;

UPDATE INVENTORY
    SET expiryDate = to_date('30.01.2020', 'dd.MM.yyyy') WHERE idIngredient = 1;
    
SELECT * FROM PERSONALNOTIFICATION;
-- -------------------------------
-- Endergebnis: Neuer Datensatz in der Tabelle "PersonalNotification"	
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 4		--
-- -------------------------------
SELECT * FROM INVENTORY;

DELETE FROM INVENTORY WHERE idInventory = 20;

INSERT INTO INVENTORY (idInventory, idIngredient, idStore, expirydate, deliveryDate, amount, isAccessible)
    VALUES (20, 3, 1, to_date('30.01.2020', 'dd.MM.yyyy'), to_date('30.12.2019', 'dd.MM.yyyy'), 10, 1);
    
SELECT * FROM PERSONALNOTIFICATION;
-- -------------------------------
-- Endergebnis: Neuer Datensatz in der Tabelle "PersonalNotification"	
-- -------------------------------

-- ---------------------------------------
-- Fünfter Trigger: Zutat hinzug. / Update

-- Wenn ein Ingredient geupdatet wird und z.B. der Preis verändert wird,
-- muss jede Waffel mit dieser Ingredient geupdatet werden
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

-- -------------------------------
-- Test 1 zum Trigger 5		--
-- -------------------------------
SELECT price FROM PRODUCT WHERE idProduct = 5; -- Preis 2

UPDATE INGREDIENT
    SET PRICE = 1 WHERE idIngredient = 4;

SELECT price FROM PRODUCT WHERE idProduct = 5; -- Preis 2.8
-- -------------------------------
-- Endergebnis: Preis des Produktes mit der id = 5 wurde von 2 auf 2.8 erhöht
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 5		--
-- -------------------------------
SELECT price FROM PRODUCT WHERE idProduct = 5; -- Preis 2.8

UPDATE INGREDIENT
    SET PRICE = 0.5 WHERE idIngredient = 4;

SELECT price FROM PRODUCT WHERE idProduct = 5; -- Preis 2.3
-- -------------------------------
-- Endergebnis: Preis des Produktes mit der id = 5 wurde von 2.8 auf 2.3 verringert.
-- -------------------------------

-- ---------------------------------------
-- Sechster Trigger: Waffel hinzug. / Update

-- Wenn eine neue Waffel hinzugefügt oder geupdatet wird, soll die CreationDate auf heute gesetzt werden,
-- die ProcessingTime soll neu bestimmt werden und es soll wieder geschaut werden, wie gesund die Waffel ist
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

-- -------------------------------
-- Test 1 zum Trigger 6		--
-- -------------------------------
DELETE FROM PRODUCT WHERE idProduct = 6;
DELETE FROM WAFFLE WHERE idWaffle = 6;

INSERT INTO Product
    VALUES (product_t(6, 6, 2, 'Waffel Ohne Alles 2'));

INSERT INTO Waffle
    VALUES (waffle_t(6, 6, 2, 'Waffel Ohne Alles', 6, 'Berndt', to_date('31.12.2020', 'dd.MM.yyyy'), NULL, NULL));

SELECT * FROM Waffle;
-- -------------------------------
-- Endergebnis: Creationdate der neuen Waffel wurde auf heute gesetzt, processingTime wurde berechnet und healty wurde auf Gesund gesetzt	
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 6		--
-- -------------------------------
UPDATE WAFFLE w SET
    w.name = 'Waffle Name geändert' WHERE idProduct = 1;

SELECT * FROM Waffle;
-- -------------------------------
-- Endergebnis: Creationdate der neuen Waffel wurde auf heute gesetzt, processingTime wurde berechnet und healty wurde auf Gesund gesetzt	
-- -------------------------------

-- ---------------------------------------
-- Instead of Trigger: WaffleConstruction (7)
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

-- -------------------------------
-- Test 1 zum Trigger 7		--
-- -------------------------------
SELECT * FROM WAFFLECONSTRUCTION; -- ProductName ist hier noch "Bananenwaffel"
SELECT * FROM WAFFLE; 	-- Name ist hier noch "Bananenwaffel"

Update WaffleConstruction
    SET product_name = 'Gesunde Bananenwaffel' WHERE product_name = 'BananenWaffel';
-- -------------------------------
-- Endergebnis: Ausgabe Aus "BananenWaffel" wurde "Gesunde BananenWaffel" in der Waffle Table

SELECT * FROM WAFFLECONSTRUCTION; -- ProductName ist jetzt "Gesunde BananenWaffel"

SELECT * FROM WAFFLE; -- Name ist jetzt "Gesunde BananenWaffel"
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 7		--
-- -------------------------------
SELECT * FROM WAFFLECONSTRUCTION; -- Amount bei "Gesunde BananenWaffel" ist hier 10
SELECT * FROM WAFFLEINGREDIENT; -- Amount bei "Gesunde BananenWaffel" / idIngredient 1 ist hier 10

UPDATE WaffleConstruction
    SET amount = '20' WHERE product_name = 'Gesunde Bananenwaffel';
-- -------------------------------
-- Endergebnis: Aus dem Amount "10" der "Gesunden BananenWaffel" wird "20"

SELECT * FROM WAFFLECONSTRUCTION; -- Amount bei "Gesunde BananenWaffel" ist hier jetzt 20

SELECT * FROM WAFFLEINGREDIENT WHERE idIngredient = 1; -- Amount ist jetzt 20
-- -------------------------------


