namespace WaffleDB
{    
    public class ProductWaffle 
    {
        public Waffle WaffleElement { get; set; }
        public Product ProductElement { get; set; }

        public string GenerateSelectStatementGetViaID
        {
            get =>
                "select * from Waffle " +
                "left join Product on  Waffle.idWaffle = Product.idProduct";
        }        
    }
}
