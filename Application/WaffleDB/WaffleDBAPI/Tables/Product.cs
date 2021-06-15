namespace WaffleDB
{
    public class Product : IDataBaseTable
    {
        public int idProduct { get; set; }
        public int idNuIn { get; set; }
        public float price { get; set; }
        public string name { get; set; }

        public string TableName => "Product";
        public string UpdateCommand =>
             "UPDATE " + TableName + " SET " +
             "price = " + price + ", " +
             "name = \"" + name + "\"" +
             " WHERE idProduct = " + idProduct +
            " AND idNuIn = " + idNuIn;
        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idProduct + "," +
            idNuIn + "," +
            price + "," +
            "\"" + name + "\"" +
            ")";

        public override string ToString()
        {
            return
                "<Product> idProduct:" + idProduct +
                " idNuIn:" + idNuIn +
                " price:" + price +
                " name:" + name;
        }
    }
}