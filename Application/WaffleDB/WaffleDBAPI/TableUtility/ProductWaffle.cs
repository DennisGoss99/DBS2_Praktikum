using System;

namespace WaffleDB
{    
    public class ProductWaffle : IProduct, IWaffle
    {
        //--- Product ------------------------------------
        public int idProduct { get; set; }
        public int idNuIn { get; set; }
        public float _price { get; set; }
        public float price 
        {
            get { return _price * 1.19f; }

            set { _price = value; } 
        
        }

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


        public void Set(Product product, Waffle waffle)
        {
            idProduct = product.idProduct;
            idNuIn = product.idNuIn;
            _price = product.price;
            name = product.name;

            idWaffle = waffle.idWaffle;
            creatorName = waffle.creatorName;
            creationDate = waffle.creationDate;
            processingTimeSec = waffle.processingTimeSec;
            healty = waffle.healty;
        }
    }
}
