using System;

namespace WaffleDB
{
    public class Inventory : IDataBaseTable, IInventory
    {
        public int idInventory { get; set; }
        public int idIngredient { get; set; }
        public int idStore { get; set; }
        public DateTime expiryDate { get; set; }
        public DateTime deliveryDate { get; set; }
        public int amount { get; set; }
        public int isAccessible { get; set; }

        public Inventory() : this(-1, -1, -1, DateTime.Now.AddDays(60), DateTime.Now, -1, -1)
        {

        }

        public Inventory(int idInventory, int idIngredient, int idStore, DateTime expiryDate, DateTime deliveryDate, int amount, int isAccessible)
        {
            this.idInventory = idInventory;
            this.idIngredient = idIngredient;
            this.idStore = idStore;
            this.expiryDate = expiryDate;
            this.deliveryDate = deliveryDate;
            this.amount = amount;
            this.isAccessible = isAccessible;
        }

        public string TableName => "Inventory";
        public string UpdateCommand =>
             "UPDATE " + TableName + " SET " +
             "idStore = " + idStore + ", " +
             "expiryDate = \"" + expiryDate + "\", " +
             "deliveryDate = \"" + deliveryDate + "\", " +
             "amount = " + amount + ", " +
             "isAccessible = " + isAccessible +
             " WHERE idInventory = " + idInventory;
        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idInventory + "," +
            idIngredient + "," +
            idStore + "," +
            "\"" + expiryDate + "\"," +
            "\"" + deliveryDate + "\"," +
            amount + "," +
            isAccessible +
            ")";

        public override string ToString()
        {
            return
                "<Inventory> idInventory:" + idInventory +
                " idIngredient:" + idIngredient +
                " idStore:" + idStore +
                " idStore:" + idStore +
                " expiryDate:" + expiryDate +
                " deliveryDate:" + deliveryDate +
                " amount:" + amount +
                " isAccessible:" + isAccessible;
        }
    }
}
