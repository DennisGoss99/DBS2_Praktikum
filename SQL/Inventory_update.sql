-- ------------------------------------------------------------------------- 
-- DB2 - Lukas Momberg - 26.05.2021 @ 23:40
-- ------------------------------------------------------------------------- 
-- NOT CURRENTLY FUNCTIONING!!!!!
-- ------------------------------------------------------------------------- 

DROP PROCEDURE InventoryUpdate;

-- - UpdateInventory('StoreName', 'Banane', 3, 'add')
CREATE PROCEDURE InventoryUpdate 
(
    storeName IN VARCHAR2,
    ingredientName  IN VARCHAR2,
    ingredientAmount IN INT,
    calcModeString IN VARCHAR -- add or sub
)
IS
    storeID INT;
    hasIngreadient BOOLEAN;
    amountOfIngreadients INT;

    CURSOR storeCursor IS 
        SELECT WAFFLESTORE.idstore 
        FROM WAFFLESTORE 
        WHERE wafflestore.name 
        LIKE storeName;
    
    CURSOR ingredientCursor IS 
        SELECT EXISTS
        (    
            SELECT INGREDIENT.NAME
            FROM INGREDIENT
            WHERE INGREDIENT.NAME
            LIKE ingredientName
        ) as HasINGREDIENTFound;

    CURSOR ingredientAmountCursor IS 
        SELECT 
        count(ingredient.idingredient) as countedAmount;
        FROM INGREDIENT
        WHERE INGREDIENT.NAME
        LIKE ingredientName;  
        
DECLARE
    -- ErrorCodes --------------------------------------------------------------
    NotEnoghIngredientsExeption EXCEPTION;
    PRAGMA exception_init(NotEnoghIngredientsExeption, -2000);
    
    NoStoreWithThatNameExeption EXCEPTION;
    PRAGMA exception_init(NoStoreWithThatNameExeption, -2001);
    
    InvalidModeExeption EXCEPTION;
    PRAGMA exception_init(InvalidModeExeption, -2002);
    
    NoIngredientWithThatNameExeption EXCEPTION;
    PRAGMA exception_init(NoIngredientWithThatNameExeption, -2003);
    -- -------------------------------------------------------------------------    
BEGIN  
   
    -- Check if this store exist -----------------------------------------------
   OPEN storeCursor;
   FETCH storeCursor INTO storeID;
   EXIT WHEN storeCursor%NOTFOUND;
   CLOSE storeCursor;
   
    IF storeID == null THEN
        RAISE NoStoreWithThatNameExeption;
    END IF;
   -- --------------------------------------------------------------------------
        
    -- Check if this ingridient already exists ---------------------------------
    OPEN ingredientCursor;
    FETCH ingredientCursor INTO hasIngreadient;
    EXIT WHEN ingredientCursor%NOTFOUND;
    CLOSE ingredientCursor;
    -- -------------------------------------------------------------------------
    
    -- Count ingredient Amount -------------------------------------------------
    OPEN ingredientAmountCursor;
    FETCH ingredientAmountCursor INTO amountOfIngreadients;
    EXIT WHEN ingredientAmountCursor%NOTFOUND;
    CLOSE ingredientAmountCursor;
    -- -------------------------------------------------------------------------
    
    -- Select Mode -------------------------------------------------------------    
    CASE calcModeString
        WHEN "add" THEN      
            IF hasIngreadient THEN     
                -- There is already an ingreadient, add to it. -----------------
                UPDATE INVENTORY 
                SET amount = amount + ingredientAmount
                    
                WHERE INGREDIENT.NAME LIKE ingredientName
                AND
                WHERE wafflestore.name LIKE storeName;   
                -- -------------------------------------------------------------
                
            ELSE
                -- There is no Ingreadient, add a new --------------------------
                INSERT INTO INVENTORY 
                `idingredient`,
                `idStore`,
                `deliverydate`, 
                `amount`    
    
                VALUES
                (
                    storeID,
                    (select `ingredient`.`name` from `ingredient` where `ingName` like `ingredientName`),
                    sysDate(),
                    ingredientAmount
                );   
                -- -------------------------------------------------------------
            END IF; 
            
        WHEN "sub" THEN 
            IF hasIngreadient THEN
                IF amountOfIngreadients == ingredientAmount THEN
                    -- We take the same amount of what is left -----------------
                    DELETE FROM INVENTORY                         
                    LEFT JOIN WAFFLESTORE ON inventory.idstore = wafflestore.idstore           
                    WHERE INGREDIENT.NAME LIKE ingredientName
                    AND
                    WHERE wafflestore.name LIKE storeName;
                    -- ---------------------------------------------------------     
                ELSE IF ingredientAmount < ingredientAmount THEN
                    -- There are not enogh. Throw exeption. --------------------
                    RAISE NotEnoghIngredientsExeption;
                    -- ---------------------------------------------------------                     
                ELSE
                    -- There are enogh the take. -------------------------------                    
                    UPDATE INVENTORY 
                    SET amount = amount - ingredientAmount
                    
                    WHERE INGREDIENT.NAME LIKE ingredientName
                    AND
                    WHERE wafflestore.name LIKE storeName;
                    -- ---------------------------------------------------------                
                END IF;                
            ELSE
                -- ERROR - ingredient does not exist!
                RAISE NoIngredientWithThatNameExeption;   
            END IF;            
        ELSE RAISE InvalidModeExeption;
    END;
    -- -------------------------------------------------------------------------    
END;
