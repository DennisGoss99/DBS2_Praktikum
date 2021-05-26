DROP PROCEDURE InventoryUpdate;

CREATE PROCEDURE InventoryUpdate 
AS
BEGIN
    -- Delete what is expired
    DELETE FROM inventory 
    WHERE expiryDate < GETDATE();
END;