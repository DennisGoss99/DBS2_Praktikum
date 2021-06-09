namespace WaffleDB
{
    public class WaffleIngredient : IDataBaseTable
    {
        public int idIngredient { get; set; }
        public int idWaffle { get; set; }
        public int amount { get; set; }


        public WaffleIngredient() : this(-1, -1, -1)
        {

        }

        public WaffleIngredient(int ingredientID, int waffleID, int amountOf)
        {
            idIngredient = ingredientID;
            idWaffle = waffleID;
            amount = amountOf;
        }

        public string TableName => "WaffleIngredient";
        public string UpdateCommand => 
            "UPDATE " + TableName + 
            " SET amount = " + amount + 
            " WHERE idIngredient = " + idIngredient + 
            " AND idWaffle = " + idWaffle;
        public string InsertCommand => 
            "INSERT INTO " + TableName +
            " VALUES(" + 
            idIngredient + "," +
            idWaffle + "," +
            amount + 
            ")";
    }
}
