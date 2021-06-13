namespace WaffleDB
{
    public class ProductOrder : IDataBaseTable
    {
        public int idOrder { get; set; }
        public int idProduct { get; set; }
        public int amount { get; set; }
        public int calculatedTime { get; set; }

        public string TableName => "ProductOrder";
        public string UpdateCommand =>
             "UPDATE " + amount + " SET " +
             "message = " + calculatedTime + 
             " WHERE idOrder = " + idOrder +
             " AND idProduct = " + idProduct;
        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idOrder + "," +
            idProduct + "," +
            amount + "," +
            calculatedTime +
            ")";

        public override string ToString()
        {
            return
                "<ProductOrder> idOrder:" + idOrder +
                " idProduct:" + idProduct +
                " amount:" + amount +
                " calculatedTime:" + calculatedTime;
        }
    }
}
