using System;

namespace WaffleDB
{    
    public class ProductWaffle : IProduct, IWaffle
    {
        //--- Product ------------------------------------
        public int idProduct { get; set; }
        public int idNuIn { get; set; }
        public float price { get; set; }
        public string name { get; set; }
        //------------------------------------------------

        //--- Waflle -------------------------------------
        public int idWaffle { get; set; }
        public string creatorName { get; set; }
        public DateTime creationDate { get; set; }
        public int processingTimeSec { get; set; }
        public string healty { get; set; }
        //------------------------------------------------  

        public static string SQLSelectCommand
        {
            get =>
                "select * from Waffle " +
                "inner join Product on Waffle.idWaffle = Product.idProduct";
        }        
    }
}
