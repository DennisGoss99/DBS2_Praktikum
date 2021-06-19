namespace WaffleDB
{
    public class ProductAddition : IProduct, IAddition
    {
        //--- Product ------------------------------------
        public int idProduct { get; set; }
        public int idNuIn { get; set; }
        public float price { get; set; }
        public string name { get; set; }
        //------------------------------------------------

        //--- Addition -----------------------------------
        public int idAddition { get; set; }
        public string optComment { get; set; }
        //-------------------------------------------------

        public ProductAddition() : this(-1)
        {

        }

        public ProductAddition(int id)
        {
            idProduct = id;
            idNuIn = -1;
            price = id;
            name = null;
            idAddition = id;
            optComment = null;
        }

        public static string SQLSelectCommand 
        {
            get => 
                "select * from Addition" +
                " inner join Product on Addition.idAddition = Product.idProduct";
        }
    }
}
