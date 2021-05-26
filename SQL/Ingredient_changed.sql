-- -----------------------------------------------------------------------------
drop TRIGGER IngredientChanged;

CREATE OR REPLACE TRIGGER IngredientChanged

-- Beim Hinzufügen oder aktualisieren einer Zutat (in einem Rezept?), 
Before INSERT OR DELETE OR UPDATE ON WAFFLEINGREDIENT 

-- soll der Preis aller Waffeln mit einem Rezept, 
for each row 

-- welches die betreffende Zutat referenziert, aktualisiert werden
BEGIN     
    UPDATE Product set price =
    (
        select sum(price * amount) as totalprice from WAFFLEINGREDIENT
        
        left join INGREDIENT ON WAFFLEINGREDIENT.idingredient = INGREDIENT.idIngredient        
    );
    
END;
-- ----------------------------------------------------------------------------