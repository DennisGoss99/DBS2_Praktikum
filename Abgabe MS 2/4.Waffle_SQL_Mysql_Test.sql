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
DROP PROCEDURE IF EXISTS `NotifyPersonal`;
DELIMITER //

CREATE PROCEDURE `NotifyPersonal` (s_reason VARCHAR(255), s_ingredient INT, s_store INT)
BEGIN 
	DECLARE v_message VARCHAR(255);
    DECLARE v_name VARCHAR(255);
    DECLARE v_Ingredient_name VARCHAR(255);
    DECLARE v_max_p_notification_id INT;
    
	SELECT w.name INTO v_name FROM WaffleStore w WHERE idStore = s_store;
    SELECT name INTO v_Ingredient_name FROM INGREDIENT i WHERE i.idingredient = s_ingredient;
    
    SELECT (IFNULL(MAX(idNotification) + 1, 1)) INTO v_max_p_notification_id FROM PERSONALNOTIFICATION;
    
	CASE s_reason
        WHEN 'niedrig' THEN SET v_message = 'Angestellte des Geschäfts ' || v_name ||'. Bitte '|| v_Ingredient_name ||' nachbestellen';
        WHEN 'abgelaufen' THEN SET v_message = 'Angestellte des Geschäfts ' || v_name ||'. Bitte ' ||''|| v_Ingredient_name ||' entsorgen';
        WHEN 'gesperrt' THEN SET v_message = 'Angestellte des Geschäfts ' || v_name || ', ' || v_Ingredient_name || ' ist bis auf weiteres gesperrt';
    END CASE;
    
    INSERT INTO PersonalNotification (idNotification, idStore, message, messageReason, idIngredient, ingredientName, time)
        VALUES (v_max_p_notification_id, s_store, v_message, s_reason, s_ingredient, v_Ingredient_name, SYSDATE());
END //

DELIMITER ;

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
-- idStore -> Store id
-- in_idIngredient -> Ingredient id
-- ingredientAmount -> Anzahl der Ingredient, die entnommen / hinzugefügt werden soll
-- calcModeString -> Operator
-- expiryDateOnInsert -> Expiry Datum des vergangegen lebensmittels
-- deliveryDateOnInsert -> Delivery Datum des vergangegen Lebensmittels

-- Diese Prozedur managet das Lager, indem entweder Zutaten dem Lager entnommen werden können 
-- (calcModeString = 'sub') oder Zutaten dem Lager hinzugefügt werden (calcModeString = 'add')
-- ---------------------------------------
DROP PROCEDURE IF EXISTS `InventoryUpdate`;
DELIMITER //

CREATE PROCEDURE `InventoryUpdate` (
	in_idStore INT,
    in_idIngredient INT,
    ingredientAmount INT,
    calcModeString VARCHAR(255), -- add or sub
    
    expiryDateOnInsert DATE,
    deliveryDateOnInsert DATE
)
BEGIN 
    DECLARE v_hasIngreadient BOOLEAN;
    DECLARE v_amountOfIngreadients INT;
    DECLARE v_ingreadientsSearchResults INT;
    
    DECLARE v_max_idIngredient INT;
    
    DECLARE v_currentIngredientAmount INT;
    DECLARE v_deleteID INT;
    DECLARE v_deleteAmount INT;
    
	-- Check if this ingridient already exists --
    SELECT count(*) INTO v_ingreadientsSearchResults FROM INGREDIENT WHERE INGREDIENT.idIngredient = in_idIngredient;
    SET v_hasIngreadient = v_ingreadientsSearchResults > 0;
    
    -- Count ingredient Amount --
    SELECT sum(amount) INTO v_amountOfIngreadients
    FROM INVENTORY
    WHERE 
    (
        inventory.idingredient = in_idIngredient
        AND
        inventory.idstore = in_idStore  
        AND
        INVENTORY.expirydate >= sysDate() 
    ); 
       
    -- Select Mode --   
    IF  calcModeString like 'add' THEN
		IF v_hasIngreadient THEN    
			-- Add new ingreadient --
            Select MAX(idInventory) from INVENTORY INTO v_max_idIngredient;
            SET v_max_idIngredient = v_max_idIngredient + 1;
            
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
				v_max_idIngredient,
				in_idIngredient,
				in_idStore,
				expiryDateOnInsert,
				deliveryDateOnInsert,
				ingredientAmount,
				1
			);
         ELSE 
			-- There is no Ingreadient, we can't add it--
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No Ingredient With That Name'; 
        END IF;
     ELSEIF calcModeString like 'sub' THEN 
     
		IF v_hasIngreadient THEN -- TRUE
			IF v_amountOfIngreadients = ingredientAmount THEN -- TRUE
				-- We take the same amount of what is left -
				DELETE FROM INVENTORY                    
				WHERE 
				(   
					inventory.idingredient = in_idIngredient
					AND
					inventory.idstore = in_idStore
				);
				-- ---------------------------------------------------------     
			ELSEIF ingredientAmount < ingredientAmount THEN
				-- There are not enogh. Throw exeption. --------------------
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not Enogh Ingredients';                   
			ELSE                    
				-- There are enough the take. -------------------------------    
				SET v_currentIngredientAmount = ingredientAmount;
		
				WHILE v_currentIngredientAmount > 0 DO
                                            
					SELECT idinventory INTO v_deleteID FROM inventory
					WHERE 
					(
						inventory.idingredient = in_idIngredient
						AND
						inventory.idstore = in_idStore 
						AND
						INVENTORY.expirydate >= CURRENT_TIMESTAMP
					)
					LIMIT 1;                    
                        
					-- Get amount
					SELECT amount INTO v_deleteAmount FROM inventory
					WHERE inventory.idinventory = v_deleteID;
                        
					IF v_deleteAmount > v_currentIngredientAmount THEN
						-- Reduce amount
						UPDATE inventory SET amount = v_deleteAmount - v_currentIngredientAmount
							WHERE inventory.idinventory = v_deleteID;
					ELSE
						Delete from inventory 
                            WHERE inventory.idinventory = v_deleteID;
					END IF;
                        
					-- Reduce
					SET v_currentIngredientAmount = v_currentIngredientAmount - v_deleteAmount;                        
				END WHILE;                                
			END IF;                
		ELSE
			-- ERROR - ingredient does not exist!
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No Ingredient With That Name'; 
           END IF;            
	ELSE                
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid Mode'; 
     END IF;        
END //

DELIMITER ;


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

CALL InventoryUpdate(1, 3, 1, 'add', '2025-01-30', '2026-01-30');

SELECT * FROM INVENTORY;
-- -------------------------------
-- Endergebnis: Es wurde ein neuer Datensatz im Inventory hinzugefügt:
-- Datensatz -> "4, 3, 1, 30.01.25, 30.01.26, 1, 1"
-- -------------------------------


-- ---------------------------------------
-- Dritte Prozedur: Lager aktualisieren und Ingredient hinzufügen (3)

-- input: 
-- s_idProduct -> Productid
-- s_idOrder -> Order id
-- s_extenal_amount -> Anzahl der schleifendurchläufe

-- Diese Prozedur holt alle IngredientInformationen der Waffel mit der oben angegebenen "ProductId"
-- entnimmt dann mit diesen Informationen zusätzlich noch die zuvor gespeicherten deliveryDatum und
-- expiryDatum und fügt dann dem Inventory die Ingredients der gefundenen Waffel wieder hinzu.
-- Dabei wird auf die Prozedur "InventoryUpdate" zugegriffen.
-- ---------------------------------------
DROP PROCEDURE IF EXISTS `OnInventoryAdd`;
DELIMITER //

CREATE PROCEDURE `OnInventoryAdd` (
    s_idProduct INT,
    s_idOrder INT,
    s_extenal_amount INT
)
BEGIN 
	DECLARE loop_counter INT DEFAULT s_extenal_amount;
    DECLARE done1, done2 BOOLEAN DEFAULT FALSE;
    
    DECLARE v_store INT;
    DECLARE v_waffle_id INT;
    
    DECLARE v_operator VARCHAR(3) DEFAULT 'add';
    
    DECLARE v_cursor_ingredientid INT;
    DECLARE v_cursor_amount INT;
    
    DECLARE v_cursor_expiryDate DATE;
    DECLARE v_cursor_deliveryDate DATE;
    
    DECLARE v_Ingredient_Cursor_On_Insert CURSOR FOR
        SELECT idIngredient, amount FROM WAFFLEINGREDIENT WHERE idWaffle = v_waffle_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = TRUE;
    
    SELECT idStore INTO v_store FROM WAFFLEORDER WHERE idOrder = s_idOrder;
    SELECT idWaffle INTO v_waffle_id FROM Waffle WHERE idWaffle = s_idProduct;

	REPEAT
       OPEN v_Ingredient_Cursor_On_Insert;
       loop1 : LOOP
          FETCH FROM v_Ingredient_Cursor_On_Insert INTO v_cursor_ingredientId, v_cursor_amount;
          
          IF done1 THEN
             CLOSE v_Ingredient_Cursor_On_Insert;
             LEAVE loop1;
		  END IF;
          
          BLOCK1 : BEGIN
          
            DECLARE v_Ingredient_Cursor_On_Delete CURSOR FOR
					SELECT expiryDate, deliveryDate FROM Inventory WHERE idIngredient = v_cursor_ingredientid;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;
            
            OPEN v_Ingredient_Cursor_On_Delete;
            loop2 : LOOP
               FETCH FROM v_Ingredient_Cursor_On_Delete INTO v_cursor_expiryDate, v_cursor_deliveryDate;
               
               IF done2 THEN
                  SET done2 = FALSE;
                  LEAVE loop2;
			   END IF;
               
            END LOOP loop2;
		 END BLOCK1;
	   END LOOP loop1;
       CALL InventoryUpdate(v_store, v_cursor_ingredientId, v_cursor_amount, v_operator, v_cursor_expiryDate, v_cursor_deliveryDate);
       SET loop_counter = loop_counter - 1;
    UNTIL loop_counter = 0
    END REPEAT;

END //

DELIMITER ;

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
-- s_idProduct -> Productid
-- s_idOrder -> Order id
-- s_extenal_amount -> Anzahl der schleifendurchläufe

-- Diese Prozedur holt alle IngredientInformationen der Waffel mit der oben angegebenen "ProductId"
-- und fügt diese dann dem Inventar wieder hinzu. Die Prozedur wird dabei "s_external_amount"-times wiederholt.
-- Dabei wird auf die Prozedur "InventoryUpdate" zugegriffen.
-- ---------------------------------------
DROP PROCEDURE IF EXISTS `OnInventoryDelete`;
DELIMITER //

CREATE PROCEDURE `OnInventoryDelete`(
    s_idProduct INT,
    s_idOrder INT,
    s_extenal_amount INT
)
BEGIN
    DECLARE loop_counter INT DEFAULT s_extenal_amount;
    DECLARE max_row INT DEFAULT 0;
    
    DECLARE v_store INT;
    DECLARE v_waffle_id INT;
    
    DECLARE v_cursor_ingredientid INT;
    DECLARE v_cursor_amount INT;
    
    DECLARE v_operator VARCHAR(3) DEFAULT 'sub';
    
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE v_Ingredient_Cursor_On_Insert CURSOR FOR SELECT idIngredient, amount FROM WAFFLEINGREDIENT WHERE idWaffle = v_waffle_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT idStore INTO v_store FROM WAFFLEORDER WHERE idOrder = s_idOrder;
    SELECT idWaffle INTO v_waffle_id FROM Waffle WHERE idWaffle = s_idProduct;
    
    REPEAT
	OPEN v_Ingredient_Cursor_On_Insert;
		cursor_loop : LOOP
        FETCH v_Ingredient_Cursor_On_Insert INTO v_cursor_ingredientId, v_cursor_amount;
            
        IF done THEN 
           LEAVE cursor_loop; 
        END IF;
            
        END LOOP;
	CLOSE v_Ingredient_Cursor_On_Insert;

	SET loop_counter = loop_counter - 1;
    CALL InventoryUpdate(v_store, v_cursor_ingredientId, v_cursor_amount, v_operator, NULL, NULL); 
    UNTIL loop_counter = 0 
    END REPEAT;
  
END //

DELIMITER ;

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
-- - bruttoPreis: BruttoPreis aus der Datenbank
-- - mwst: Mehrwertsteuer, optionaler Wert. Default = 0.19 (Deutschland)

-- Funktion berechnet den nettoPreis einer Waffel, damit dieser Preis
-- später der WaffleOrder zugeordnet werden kann
-- ---------------------------------------
DROP FUNCTION IF EXISTS `GrossNetCalculator`;
DELIMITER //

CREATE FUNCTION GrossNetCalculator(bruttoPreis FLOAT, mwst FLOAT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE Ergebnis FLOAT;
    DECLARE myMwst FLOAT;
    
    SET myMwst = IFNULL(mwst, 0.19);
    SET Ergebnis = bruttoPreis * (1 + myMwst);
    
    Return Ergebnis;
END //

DELIMITER ;

-- -------------------------------
-- Test 1 zur Funktion 1	--
-- -------------------------------
SET @v_bruttoPreis = GrossNetCalculator(120, NULL);

SELECT @v_bruttoPreis;
-- -------------------------------
-- Endergebnis: Ausgabe 148.2
-- -------------------------------

-- -------------------------------
-- Test 2 zur Funktion 1	--
-- -------------------------------
SET @v_bruttoPreisSchweiz = GrossNetCalculator(120, 0.077);

SELECT @v_bruttoPreisSchweiz;
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
DROP FUNCTION IF EXISTS `NutritionCalculator`;
DELIMITER //

CREATE FUNCTION NutritionCalculator(in_idNui INT)
RETURNS VARCHAR(64)
DETERMINISTIC
BEGIN
    DECLARE v_calories FLOAT;
    DECLARE v_saturatedFat FLOAT;
    DECLARE v_transFat FLOAT;
    DECLARE v_carbohydrates FLOAT;
    DECLARE v_sugar FLOAT;
    DECLARE v_protein FLOAT;
    DECLARE v_salt FLOAT;
    
    DECLARE myHealtyCalories FLOAT DEFAULT 350;
    DECLARE myHealtySugar FLOAT DEFAULT 10;
    DECLARE Ergebnis VARCHAR(64);
    
    SELECT CALORIES, SATURATEDFAT, TRANSFAT, CARBOHYDRATES, SUGAR, PROTEIN, SALT 
    INTO  v_calories, v_saturatedFat, v_transFat, v_carbohydrates, v_sugar, v_protein, v_salt 
    FROM NutritionalInformation WHERE idNuIn = in_idNui;
    
    IF (v_calories > myHealtyCalories) OR (v_sugar > myHealtySugar) THEN
       IF (v_transFat > 3) OR (v_saturatedFat > 15) OR (v_sugar > 10) THEN
            SET Ergebnis = 'Ungesund';
       ELSE 
            SET Ergebnis = 'Mäßig Gesund';
       END IF;
	ELSE
	   SET Ergebnis = 'Gesund';
    END IF;
    
    Return Ergebnis;
END //

DELIMITER ;

-- -------------------------------
-- Test 1 zur Funktion 2	--
-- -------------------------------
SELECT * FROM PRODUCT WHERE idNuIn = 1;
SELECT * FROM NUTRITIONALINFORMATION WHERE idNUIN = 1;

SET @v_gesund = NutritionCalculator(1); -- Bananenwaffel;

SELECT @v_gesund;

-- -------------------------------
-- Endergebnis: Ausgabe Gesund		
-- -------------------------------

-- -------------------------------
-- Test 2 zur Funktion 2	--
-- -------------------------------
SELECT * FROM PRODUCT WHERE idNUIN = 2;
SELECT * FROM NUTRITIONALINFORMATION WHERE idNUIN = 2;

SET @v_mittelmaesig = NutritionCalculator(2); -- Schokowaffel

SELECT @v_mittelmaesig;
-- -------------------------------
-- Endergebnis: Ausgabe Mäßig Gesund	
-- -------------------------------

-- -------------------------------
-- Test 3 zur Funktion 2	--
-- -------------------------------
SELECT * FROM PRODUCT WHERE idNUIN = 3;
SELECT * FROM NUTRITIONALINFORMATION WHERE idNUIN = 3;

SET @v_ungesund = NutritionCalculator(3); --  Megaschokowaffel

SELECT @v_ungesund;
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
DROP FUNCTION IF EXISTS `OrderTimeCalculator`;
DELIMITER //

CREATE FUNCTION `OrderTimeCalculator`(in_idWaffle INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE i_waffletime_in_s INT DEFAULT 0;

    SELECT SUM(ing.processingTimeSec * wi.amount) INTO i_waffletime_in_s FROM WaffleIngredient wi, Ingredient ing
    WHERE wi.idWaffle = in_idwaffle AND ing.idIngredient = wi.idIngredient;
    
    RETURN i_waffletime_in_s;
END //

DELIMITER ;


-- -------------------------------
-- Test 1 zur Funktion 3	--
-- -------------------------------
SET @v_time1 = OrderTimeCalculator(1);

SELECT @v_time1;
-- -------------------------------
-- Endergebnis: 30 (sekunden)	
-- -------------------------------


-- -------------------------------
-- Test 2 zur Funktion 3	--
-- -------------------------------
SET @v_time2 = OrderTimeCalculator(2);

SELECT @v_time2;
-- -------------------------------
-- Endergebnis: 15 (sekunden)	
-- -------------------------------


-- -----------------------------------------------------
-- Trigger
-- -----------------------------------------------------

-- ---------------------------------------
-- Erster Trigger: Bestandsänderung (1)

-- Trigger kontrolliert, dass das Inventar immer eine mindestmenge hat, damit dem Kunden
-- immer die beste "User Experience" geliefert werden kann und dieser z.B nicht auf
-- bestimmte Waffeln verzichten muss.
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnInventoryUpdate`;
DELIMITER //

CREATE TRIGGER `OnInventoryUpdate`
BEFORE UPDATE ON Inventory
FOR EACH ROW
BEGIN
    DECLARE id INT DEFAULT New.idIngredient;
    DECLARE store INT DEFAULT New.idStore;
    
    IF New.Amount <> Old.Amount THEN
       IF New.Amount < 2 THEN
           SET New.isAccessible = 0;
           CALL NotifyPersonal('gesperrt', id, store);
       ELSEIF New.Amount < 5 THEN
           CALL NotifyPersonal('niedrig', id, store);
       ELSEIF New.Amount > 5 THEN
           SET New.isAccessible = 1;
       END IF;
    END IF;
END //

DELIMITER ;

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
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnProductOrderInsert`;
DELIMITER //

CREATE TRIGGER `OnProductOrderInsert`
BEFORE INSERT ON PRODUCTORDER
FOR EACH ROW
BEGIN
     DECLARE v_processingTime FLOAT;
     DECLARE v_calculatedTime FLOAT;
     
     SELECT processingTimeSec INTO v_processingTime FROM WAFFLE WHERE idWaffle = NEW.idProduct;
     
     SET v_calculatedTime = New.Amount * IFNULL(v_processingTime, 100);
     SET New.CalculatedTime = v_calculatedTime;
     
     
     CALL OnInventoryDelete(NEW.idProduct, NEW.idOrder, NEW.Amount);
END //

DELIMITER ;


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
SELECT amount FROM INVENTORY WHERE idInventory = 2;

SELECT * FROM PRODUCTORDER;

DELETE FROM PRODUCTORDER;

INSERT INTO PRODUCTORDER(idOrder, idProduct, amount, calculatedTime)
    VALUES (1, 4, 1, NULL);

SELECT amount FROM INVENTORY WHERE idInventory = 2;
-- -------------------------------
-- Endergebnis: Amount der idInventory wurde um 1 verringert, da 1 Waffeln bestellt wurde, 
-- die jeweils 2 mal eine bestimmte Ingredient brauchen
-- -------------------------------


-- ---------------------------------------
-- Dritter Trigger: Bestellung erhalten Update -- (3)

-- Update: Wenn der Kunde eine Waffel mehr bestellt, wird die Ingredient wieder dem
-- Inventar hinzugefügt. Bestellt der Kunde eine Waffel ab (z.B Amount von 2 auf 1)
-- wird dem Inventar wieder die Ingredients der Waffel hinzugefügt
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnProductOrderUpdate`;
DELIMITER //

CREATE TRIGGER `OnProductOrderUpdate`
BEFORE UPDATE ON PRODUCTORDER
FOR EACH ROW
BEGIN
     DECLARE v_amount_difference FLOAT DEFAULT Old.Amount - New.Amount;
     
     IF v_amount_difference < 0 THEN
        CALL OnInventoryDelete(Old.idProduct, Old.idOrder, ABS(v_amount_difference));
     ELSEIF v_amount_difference < 0 THEN
        CALL OnInventoryAdd(Old.idProduct, Old.idOrder, v_amount_difference);
     END IF;
END //

DELIMITER ;


-- -------------------------------
-- Test 1 zum Trigger 3		--
-- -------------------------------
UPDATE PRODUCTORDER
    SET amount = 3;

SELECT amount FROM INVENTORY WHERE idInventory = 2;
-- -------------------------------
-- Endergebnis: Amount der idInventory wurde um 2 verringert, da 1 zusätzliche Waffeln bestellt wurde, 
-- die jeweils 2 mal eine bestimmte Ingredient braucht
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 3		--
-- -------------------------------
UPDATE PRODUCTORDER
    SET amount = 1;

SELECT * FROM INVENTORY;
-- -------------------------------
-- Endergebnis: Amount der idInventory wurde um 2 erhöht, da 1 Waffel abbestellt wurde, 
-- die jeweils 2 mal eine bestimmte Ingredient braucht
-- -------------------------------

-- ---------------------------------------
-- Vierter Trigger: Bestellung erhalten Delete -- (4)

-- Delete: Storniert der Kunde eine Waffel, werden die dafür benötigten Ingredient
-- wieder dem Invetar hinzgefügt.
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnProductOrderDelete`;
DELIMITER //

CREATE TRIGGER `OnProductOrderDelete`
BEFORE DELETE ON PRODUCTORDER
FOR EACH ROW
BEGIN
   CALL OnInventoryAdd(Old.idProduct, Old.idOrder, Old.Amount);
END //

DELIMITER ;


-- -------------------------------
-- Test 1 zum Trigger 4		--
-- -------------------------------
DELETE FROM PRODUCTORDER;

SELECT * FROM INVENTORY;
-- -------------------------------
-- Endergebnis: Dem Inventory wurden alle vorher benutzen Ingredient der zuvor bestellten Waffeln
-- wieder gut geschrieben
-- -------------------------------


-- -------------------------------
-- Test 2 zum Trigger 4		--
-- -------------------------------
-- ANALOG, SIEHE TEST 1
-- -------------------------------
-- Endergebnis: ANALOG, SIEHE TEST1
-- -------------------------------


-- ---------------------------------------
-- Fünfter Trigger: Bestellung abges.   (5)

-- Wenn die Bestellung abgeschlossen wurde, soll die SchlussRechnung bestimmt werden.
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnFinishOrder`;
DELIMITER //

CREATE TRIGGER `OnFinishOrder`
BEFORE UPDATE ON WAFFLEORDER
FOR EACH ROW
BEGIN
    DECLARE v1 INT DEFAULT 0;
    
    IF (New.paymentStatus = 1) THEN
	   SELECT SUM(product.price * productorder.amount) INTO v1
       FROM productorder
       inner join product on productorder.idproduct = product.idproduct
       WHERE IDORDER = NEW.idOrder
       GROUP BY productorder.idorder;
       
       SET NEW.totalamount = v1;
    END IF;
END //

DELIMITER ;


-- -------------------------------
-- Vorbedingung zum Test	--
-- -------------------------------
UPDATE waffleorder
	SET paymentstatus = 0, totalamount = NULL;

DELETE FROM PRODUCTORDER;

INSERT INTO PRODUCTORDER(idOrder, idProduct, amount, calculatedTime)
    VALUES (1, 4, 2, NULL);

-- -------------------------------
-- Test 1 zum Trigger 5		--
-- -------------------------------
UPDATE waffleorder
	SET paymentstatus = 1 WHERE idOrder = 1;
		
Select * from waffleorder;
-- -------------------------------
-- Endergebnis: Totalamount wurde berechnet
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 5		--
-- -------------------------------
UPDATE waffleorder
  SET paymentstatus = 2 WHERE idorder = 1;
		
Select * from  waffleorder;
-- -------------------------------
-- Endergebnis: Zahlung ist abgeschlossen
-- -------------------------------


-- ---------------------------------------
-- Sechster Trigger: Lebensmittel abgel. (6)

-- Trigger der feuert, wenn es ein Update auf Inventory gibt. 
-- Prüft ob die geupdatete Zutat schon abgelaufen ist und falls sie es ist führt er die Prozedur benachrichtigen aus.
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnInventoryUpdateInsert`;
DELIMITER //

CREATE TRIGGER `OnInventoryUpdateInsert`
BEFORE INSERT ON INVENTORY
FOR EACH ROW
BEGIN
     DECLARE id INT DEFAULT New.idIngredient;
     DECLARE store INT DEFAULT New.idStore;
     
     IF New.ExpiryDate < sysdate() THEN
          CALL NotifyPersonal('abgelaufen', id, store);
	 END IF;
END //

DELIMITER ;

-- -------------------------------
-- Test 1 zum Trigger 6		--
-- -------------------------------
SELECT * FROM INVENTORY;

DELETE FROM INVENTORY WHERE idInventory = 20;

INSERT INTO INVENTORY (idInventory, idIngredient, idStore, expirydate, deliveryDate, amount, isAccessible)
    VALUES (20, 3, 1, '2020-01-30', '2019-12-30', 10, 1);
    
SELECT * FROM PERSONALNOTIFICATION;
-- -------------------------------
-- Endergebnis: Neuer Datensatz in der Tabelle "PersonalNotification"	
-- -------------------------------

-- ---------------------------------------
-- Siebter Trigger: Lebensmittel abgel. Update -- (7)

-- Trigger der feuert, wenn es ein Update auf Inventory gibt. 
-- Prüft ob die geupdatete Zutat schon abgelaufen ist und falls sie es ist führt er die Prozedur benachrichtigen aus.
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnInventoryUpdateUpdate`;
DELIMITER //

CREATE TRIGGER `OnInventoryUpdateUpdate`
BEFORE UPDATE ON INVENTORY
FOR EACH ROW
BEGIN
     DECLARE id INT DEFAULT New.idIngredient;
     DECLARE store INT DEFAULT New.idStore;
     
     IF New.ExpiryDate < sysdate() THEN
          CALL NotifyPersonal('abgelaufen', id, store);
	 END IF;
END //

DELIMITER ;

-- -------------------------------
-- Test 1 zum Trigger 7		--
-- -------------------------------
SELECT * FROM INVENTORY;

UPDATE INVENTORY
    SET expiryDate = '2020-01-30' WHERE idIngredient = 1;
    
SELECT * FROM PERSONALNOTIFICATION;
-- -------------------------------
-- Endergebnis: Neuer Datensatz in der Tabelle "PersonalNotification"	
-- -------------------------------


-- ---------------------------------------
-- Achter Trigger: Zutat hinzug. / Update Update (8)

-- Wenn ein Ingredient geupdatet wird und z.B. der Preis verändert wird,
-- muss jede Waffel mit dieser Ingredient geupdatet werden
-- ---------------------------------------
DROP TRIGGER IF EXISTS IngredientChanged;
DELIMITER // 

CREATE TRIGGER IngredientChanged
AFTER UPDATE ON INGREDIENT 
for each row 
BEGIN
    DECLARE v_oldPrice FLOAT;
    DECLARE v_newPrice FLOAT;
    DECLARE v_cursorID FLOAT;
    DECLARE v_cursorAmount FLOAT;

    DECLARE DONE1 BOOLEAN DEFAULT FALSE;
    DECLARE v_ingredientID FLOAT DEFAULT NEW.idIngredient ; 

    DECLARE v_waffleToChange CURSOR FOR 
        SELECT idWaffle, amount 
        FROM waffleingredient
        WHERE idingredient = v_ingredientID;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;

    OPEN v_waffleToChange;
    loop1 : LOOP
        FETCH FROM v_waffleToChange INTO v_CursorID, v_cursorAmount;

        IF DONE1 THEN
            LEAVE loop1;
        END IF;

        SET v_oldPrice = OLD.price * v_CursorAmount;
        SET v_newPrice = NEW.price * v_CursorAmount;

        UPDATE PRODUCT 
        SET price = (price - v_oldPrice) + v_newPrice
        where idproduct = v_CursorID;

    END LOOP loop1;
    CLOSE v_waffleToChange;

END //
DELIMITER ;

-- -------------------------------
-- Test 1 zum Trigger 8		--
-- -------------------------------
SELECT price FROM PRODUCT WHERE idProduct = 5; -- Preis 2

UPDATE INGREDIENT
    SET PRICE = 1 WHERE idIngredient = 4;

SELECT price FROM PRODUCT WHERE idProduct = 5; -- Preis 2.8
-- -------------------------------
-- Endergebnis: Preis des Produktes mit der id = 5 wurde von 2 auf 2.8 erhöht
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 8		--
-- -------------------------------
SELECT price FROM PRODUCT WHERE idProduct = 5; -- Preis 2.8

UPDATE INGREDIENT
    SET PRICE = 0.5 WHERE idIngredient = 4;

SELECT price FROM PRODUCT WHERE idProduct = 5; -- Preis 2.3
-- -------------------------------
-- Endergebnis: Preis des Produktes mit der id = 5 wurde von 2.8 auf 2.3 verringert.
-- -------------------------------


-- ---------------------------------------
-- Neunter Trigger: Waffel hinzug. / Update Insert - Insert (9)

-- Wenn eine neue Waffel hinzugefügt oder geupdatet wird, soll die CreationDate auf heute gesetzt werden,
-- die ProcessingTime soll neu bestimmt werden und es soll wieder geschaut werden, wie gesund die Waffel ist
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnWaffleInsert`;
DELIMITER //

CREATE TRIGGER `OnWaffleInsert`
BEFORE INSERT ON WAFFLE
FOR EACH ROW
BEGIN
    DECLARE v_processingTime FLOAT DEFAULT OrderTimeCalculator(New.idWaffle);
    DECLARE v_idNuIn INT;
    DECLARE v_nutrition VARCHAR(64);
    
    SELECT idNuIn INTO v_idNuIn FROM PRODUCT WHERE idProduct = New.IdWaffle;
    
    SET v_nutrition = NutritionCalculator(v_idNuIn);

    SET New.creationDate = SYSDATE();
    SET New.processingTimeSec = IFNULL(v_processingTime, 100);
    SET New.healty = IFNULL(v_nutrition, 'Mäßig Gesund');
END //

DELIMITER ;

-- -------------------------------
-- Test 1 zum Trigger 9		--
-- -------------------------------
DELETE FROM WAFFLE WHERE idWaffle = 6;
DELETE FROM PRODUCT WHERE idProduct = 6;

INSERT INTO Product
    VALUES (6, 6, 2, 'Waffel Ohne Alles 2');

INSERT INTO Waffle
    VALUES (6, 'Berndt', '2020-12-30', NULL, NULL);

SELECT * FROM Waffle;
-- -------------------------------
-- Endergebnis: Creationdate der neuen Waffel wurde auf heute gesetzt, processingTime wurde berechnet und healty wurde auf Gesund gesetzt	
-- -------------------------------

-- -------------------------------
-- Test 2 zum Trigger 9		--
-- -------------------------------
-- ANALOG, SIEHE TEST 1
-- -------------------------------
-- Endergebnis: ANALOG, SIEHE TEST 1
-- -------------------------------


-- ---------------------------------------
-- Zehnter Trigger: Waffel hinzug. / Update Update (10)

-- Wenn eine neue Waffel hinzugefügt oder geupdatet wird, soll die CreationDate auf heute gesetzt werden,
-- die ProcessingTime soll neu bestimmt werden und es soll wieder geschaut werden, wie gesund die Waffel ist
-- ---------------------------------------
DROP TRIGGER IF EXISTS `OnWaffleUpdate`;
DELIMITER //

CREATE TRIGGER `OnWaffleUpdate`
BEFORE INSERT ON WAFFLE
FOR EACH ROW
BEGIN
    DECLARE v_processingTime FLOAT DEFAULT OrderTimeCalculator(New.idWaffle);
    DECLARE v_idNuIn INT;
    DECLARE v_nutrition VARCHAR(64);
    
    SELECT idNuIn INTO v_idNuIn FROM PRODUCT WHERE idProduct = New.IdWaffle;
    
    SET v_nutrition = NutritionCalculator(v_idNuIn);

    SET New.creationDate = SYSDATE();
    SET New.processingTimeSec = IFNULL(v_processingTime, 100);
    SET New.healty = IFNULL(v_nutrition, 'Mäßig Gesund');
END //

DELIMITER ;


-- -------------------------------
-- Test 1 zum Trigger 10	--
-- -------------------------------
UPDATE WAFFLE SET
    creatorname = 'Waffle Name geändert' WHERE idWaffle = 1;

SELECT * FROM Waffle;
-- -------------------------------
-- Endergebnis: Creationdate der neuen Waffel wurde auf heute gesetzt, processingTime wurde berechnet und healty wurde auf Gesund gesetzt	
-- -------------------------------


-- -------------------------------
-- Test 2 zum Trigger 10	--
-- -------------------------------
-- ANALOG ZUM TEST 1
-- -------------------------------
-- Endergebnis: ANALOG ZUM TEST 1	
-- -------------------------------