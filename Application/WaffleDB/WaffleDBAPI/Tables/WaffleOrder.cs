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

        public WaffleOrder() : this(-1)
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

        public string DateFormatter(DateTime dateTime)
        {
            // 0000-00-00
            return dateTime.Year.ToString("0000") + "-" + dateTime.Month.ToString("00") + "-" + dateTime.Day.ToString("00");
        }

        public string TableName => "WaffleOrder";
        public string UpdateCommand =>
             "UPDATE " + TableName + " SET " +
             "totalAmount = " + totalAmount + "," +
             "paymentStatus = " + paymentStatus + "," +
             "orderDate = \"" + DateFormatter(orderDate) + "\"" +
             " WHERE idOrder = " + idOrder +
             " AND idStore = " + idStore;
        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idOrder + "," +
            idStore + "," +
            totalAmount + "," +
            paymentStatus + "," +
           "\"" + DateFormatter(orderDate) + "\"" +
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
