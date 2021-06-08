namespace WaffleDB
{
    public class WaffleOrder
    {
        public int idOrder { get; set; }
        public int idStore { get; set; }
        public int totalAmount { get; set; }
        public int paymentStatus { get; set; }
        public int orderDate { get; set; }
    }
}
