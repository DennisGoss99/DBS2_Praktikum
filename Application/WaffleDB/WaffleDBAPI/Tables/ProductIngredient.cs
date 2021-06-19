namespace WaffleDB
{
    public class ProductIngredient : IDataBaseTable
    {
        public int idIngredient { get; set; }
        public int idProduct { get; set; }
        public int amount { get; set; }


        public ProductIngredient() : this(-1, -1, -1)
        {

        }

        public ProductIngredient(int ingredientID, int productID, int amountOf)
        {
            idIngredient = ingredientID;
            idProduct = productID;
            amount = amountOf;
        }

        public string TableName => "ProductIngredient";
        public string UpdateCommand => 
            "UPDATE " + TableName + 
            " SET amount = " + amount + 
            " WHERE idIngredient = " + idIngredient +
            " AND idProduct = " + idProduct;
        public string InsertCommand => 
            "INSERT INTO " + TableName +
            " VALUES(" + 
            idIngredient + "," +
            idProduct + "," +
            amount + 
            ")";

        public override string ToString()
        {
            return
                "<WaffleIngredient> idIngredient:" + idIngredient +
                " idProduct:" + idProduct +
                " amount:" + amount;
        }
    }
}
