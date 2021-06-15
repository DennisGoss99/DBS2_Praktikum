namespace WaffleDB
{
    public class ProductOrder : IDataBaseTable
    {
        public int idOrder { get; set; }
        public int idProduct { get; set; }
        public int amount { get; set; }
        public int calculatedTime { get; set; }

        public ProductOrder()
        {

        }

        public ProductOrder(int idOrder, int idProduct, int amount)
        {
            this.idOrder = idOrder;
            this.idProduct = idProduct;
            this.amount = amount;
            this.calculatedTime = 0;
        }

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
