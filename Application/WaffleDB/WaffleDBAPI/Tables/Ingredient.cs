namespace WaffleDB
{
    public class Ingredient : IDataBaseTable
    {
        public int idIngredient { get; set; }
        public int idNuIn { get; set; }
        public string name { get; set; }
        public string unit { get; set; }
        public float price { get; set; }
        public int processingTimeSec { get; set; }
        public int canPutOnWaffle { get; set; }

        public string TableName => "Ingredient";
        public string UpdateCommand =>
             "UPDATE " + TableName + " SET " +
             "idNuIn = " + idNuIn + ", " +
             "name = \"" + name + "\", " +
             "unit = \"" + unit + "\", " +
             "price = " + price + ", " +
             "canPutOnWaffle = " + canPutOnWaffle + ", " +
             "processingTimeSec = " + processingTimeSec +
             " WHERE idIngredient = " + idIngredient;
        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idIngredient + "," +
            idNuIn + "," +
            "\"" + name + "\"," +
            "\"" + unit + "\"," +
            price + "," +
            canPutOnWaffle + 
            processingTimeSec +
            ")";

        public override string ToString()
        {
            return
                "<Ingredient> idIngredient:" + idIngredient +
                " idNuIn:" + idNuIn +
                " name:" + name +
                " unit:" + unit +
                " price:" + price +
                " processingTimeSec:" + processingTimeSec +
                " canPutOnWaffle:" + canPutOnWaffle;
        }
    }
}
