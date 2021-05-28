
-- TRIGGER [finish_Ordner] ----------------------------------------------------------------------------
-- 	   triggers: Update on waffleorder.paymentstatus (only update = 1)	% triggert wenn der Paymentstatus = 1 gestezt wird
-- 				 Setzt den zu bezahlenden Wert fest
-- ----------------------------------------------------------------------------------------------------


	DROP TRIGGER IF EXISTS finish_Ordner;
	DELIMITER //

	CREATE TRIGGER finish_Ordner 
	BEFORE UPDATE ON waffleorder
	FOR EACH ROW
	BEGIN     
		DECLARE v1 int;
		SET v1 = 0;
		IF (NEW.paymentstatus = 1) THEN
			SELECT SUM(product.price * productorder.amount ) INTO v1
				from productorder
				inner join product on productorder.idproduct = product.idproduct
					WHERE IDORDER = NEW.idOrder
					GROUP BY productorder.idorder;
					
			SET NEW.totalamount = v1;        
		END IF;
	END;
	//
	DELIMITER ;

	-- TEST: finish_Ordner ------------------------------------------------------------------------
	-- make sure valid Data is present
    
	-- CLEAR
        UPDATE waffleorder
		SET paymentstatus = 0, 
        totalamount = NULL;
	
    -- [1 TEST] set paymentstatus = 1
		UPDATE waffleorder
		SET paymentstatus = 1
		WHERE idorder = 0;
		
        Select * from  waffleorder;
        
    -- [1 TEST] set paymentstatus = 2
		UPDATE waffleorder
		SET paymentstatus = 2
		WHERE idorder = 1;
		
        Select * from  waffleorder;
    
	-- ---------------------------------------------------------------------------------------------



-- FUN [clac_ordertime} -------------------------------------------------------------------------------
-- 	   input:  int IDORDER							% Nimmt als Input die BestellungsID an
--	   output: int sum(processingtime * amount)		% Gibt die Bearbeitungszeit aller Bestellungen zurück
-- ----------------------------------------------------------------------------------------------------

	DROP FUNCTION IF EXISTS clac_ordertime;
	DELIMITER //

	CREATE FUNCTION clac_ordertime(
		in_idorder INT
	)
	RETURNS INT
	DETERMINISTIC
	BEGIN
		DECLARE i_ordertime_in_s INT;
		
	SELECT SUM(processingtimesec * amount) as time_in_s INTO i_ordertime_in_s
		FROM productorder
		INNER JOIN PRODUCT ON product.idproduct = productorder.idproduct
		INNER JOIN WAFFLE ON waffle.idwaffle = product.idproduct
			WHERE idorder = in_idorder
			GROUP BY idorder;
		
		Return i_ordertime_in_s;
	END //

	DELIMITER ;

	-- TEST: clac_ordertime ------------------------------------------------------------------------
	-- make sure valid Data is present
    
    -- [1 TEST] orderid = 0
	SELECT clac_ordertime(0);
    -- [2 TEST] orderid = 1
	SELECT clac_ordertime(1);
	-- ---------------------------------------------------------------------------------------------
    
    
    
-- FUN [clac_waffletime} -------------------------------------------------------------------------------
-- 	   input:  int IDWAFFLE							% Nimmt als Input die WAFFFLEID an
--	   output: int sum(processingtime * amount)		% Gibt die Bearbeitungszeit der Waffle zurück
-- ----------------------------------------------------------------------------------------------------


	DROP FUNCTION IF EXISTS clac_waffletime;
	DELIMITER //

	CREATE FUNCTION clac_waffletime(
		in_idwaffle INT
	)
	RETURNS INT
	DETERMINISTIC
	BEGIN
		DECLARE i_waffletime_in_s INT;
		
SELECT SUM(ingredient.processingtimesec * amount) as time_in_s INTO i_waffletime_in_s
    FROM WAFFLE
    INNER JOIN WAFFLEINGREDIENT ON waffle.idwaffle = waffleingredient.idwaffle
    INNER JOIN INGREDIENT ON ingredient.idingredient = waffleingredient.idingredient
        WHERE waffle.idwaffle = in_idwaffle
        GROUP BY waffle.idwaffle;
		
		Return i_waffletime_in_s;
	END //

	DELIMITER ;

	-- TEST: clac_ordertime ------------------------------------------------------------------------
	-- make sure valid Data is present
    
    -- [1 TEST] orderid = 0
	SELECT clac_waffletime(0);
    -- [2 TEST] orderid = 1
	SELECT clac_waffletime(1);
	-- ---------------------------------------------------------------------------------------------
    