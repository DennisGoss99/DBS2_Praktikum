
-- TRIGGER [finish_Ordner] ----------------------------------------------------------------------------
-- 	   triggers: Update on waffleorder.paymentstatus (only update = 1)	% triggert wenn der Paymentstatus = 1 gestezt wird
-- 				 Setzt den zu bezahlenden Wert fest
-- ----------------------------------------------------------------------------------------------------


UPDATE waffleorder
SET paymentstatus = 1
WHERE idorder = 1;
commit;


CREATE OR REPLACE TRIGGER finish_Ordner
BEFORE UPDATE ON waffleorder
FOR EACH ROW
WHEN (NEW.paymentstatus = 1)
DECLARE
    v1 int;
BEGIN   
    SELECT SUM(product.price * productorder.amount ) INTO v1
        from productorder
        RIGHT join product on productorder.idproduct = product.idproduct
            WHERE IDORDER = :NEW.idOrder
            GROUP BY productorder.idorder;
    
    :NEW.totalamount := v1;
END finish_Ordner;
/

	-- TEST: finish_Ordner ------------------------------------------------------------------------
	-- make sure valid Data is present
    
    -- CLEAR --------------------------------
        UPDATE waffleorder
		SET paymentstatus = 0, 
        totalamount = NULL;
    
    -- [1 TEST] set paymentstatus = 1 -------
		UPDATE waffleorder
		SET paymentstatus = 1
		WHERE idorder = 0;
		
        Select * from  waffleorder;
        
    -- [1 TEST] set paymentstatus = 2 -------
		UPDATE waffleorder
		SET paymentstatus = 2
		WHERE idorder = 1;
		
        Select * from  waffleorder;
    
	-- ---------------------------------------------------------------------------------------------




-- FUN [clac_ordertime] -------------------------------------------------------------------------------
-- 	   input:  int IDORDER							% Nimmt als Input die BestellungsID an
--	   output: int sum(processingtime * amount)		% Gibt die Bearbeitungszeit aller Bestellungen zurÃ¼ck
-- ----------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION clac_ordertime (in_idorder IN INT)
RETURN INT
IS
 i_ordertime_in_s INT := 0;
BEGIN

SELECT SUM(processingtimesec * amount) as time_in_s INTO i_ordertime_in_s
    FROM productorder
    INNER JOIN PRODUCT ON product.idproduct = productorder.idproduct
    INNER JOIN WAFFLE ON waffle.idwaffle = product.idproduct
        WHERE idorder = in_idorder
        GROUP BY idorder;

RETURN i_ordertime_in_s;
END clac_ordertime;
/

	-- TEST: clac_ordertime ------------------------------------------------------------------------
	-- make sure valid Data is present
    
    -- [1 TEST] idorder = 0
        begin
            dbms_output.put_line (clac_ordertime(0));
        end;
    -- [2 TEST] idorder = 1
    
        begin
            dbms_output.put_line (clac_ordertime(1));
        end;
	-- ---------------------------------------------------------------------------------------------



-- FUN [clac_waffletime] -------------------------------------------------------------------------------
-- 	   input:  int IDWAFFLE							% Nimmt als Input die WAFFFLEID an
--	   output: int sum(processingtime * amount)		% Gibt die Bearbeitungszeit der Waffle zurÃ¼ck
-- ----------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION clac_waffletime (in_idwaffle IN INT)
RETURN INT
IS
 i_waffletime_in_s INT := 0;
BEGIN

SELECT SUM(ingredient.processingtimesec * amount) as time_in_s INTO i_waffletime_in_s
    FROM WAFFLE
    INNER JOIN WAFFLEINGREDIENT ON waffle.idwaffle = waffleingredient.idwaffle
    INNER JOIN INGREDIENT ON ingredient.idingredient = waffleingredient.idingredient
        WHERE waffle.idwaffle = in_idwaffle
        GROUP BY waffle.idwaffle;

RETURN i_waffletime_in_s;
END clac_waffletime;
/

	-- TEST: clac_waffletime ------------------------------------------------------------------------
	-- make sure valid Data is present
    
    -- [1 TEST] idwaffle = 0
        begin
            dbms_output.put_line (clac_waffletime(0));
        end;
    -- [2 TEST] idwaffle = 1
    
        begin
            dbms_output.put_line (clac_waffletime(2));
        end;
	-- ---------------------------------------------------------------------------------------------






