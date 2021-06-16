using System;

namespace WaffleDB
{
    public class WaffleOrder : IDataBaseTable
    {
        public int idOrder { get; set; }
        public int idStore { get; set; }
        public float totalAmount { get; set; }
        public int paymentStatus { get; set; }
        public DateTime orderDate { get; set; }

        public WaffleOrder() : this(-1, -1,-1, -1)
        {

        }

        public WaffleOrder(int idStore) : this(-1, idStore, -1, -1)
        {

        }

        public WaffleOrder(int idOrder, int idStore, float totalAmount, int paymentStatus)
        {
            this.idOrder = idOrder;
            this.idStore = idStore;
            this.totalAmount = totalAmount;
            this.paymentStatus = paymentStatus;
            this.orderDate = DateTime.Now;
        }

        public string TableName => "WaffleOrder";
        public string UpdateCommand =>
             "UPDATE " + TableName + " SET " +
             "totalAmount = " + totalAmount + "," +
             "paymentStatus = " + paymentStatus + "," +
             "orderDate = \"" + orderDate + "\"" +
             " WHERE idOrder = " + idOrder +
             " AND idStore = " + idStore;
        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idOrder + "," +
            idStore + "," +
            totalAmount + "," +
            paymentStatus + "," +
           "\"" + orderDate + "\"" +
            ")";

        public override string ToString()
        {
            return
                "<WaffleStore> idOrder:" + idOrder +
                " idStore:" + idStore +
                " totalAmount:" + totalAmount +
                " paymentStatus:" + paymentStatus +
                " orderDate:" + orderDate;
        }
    }
}
