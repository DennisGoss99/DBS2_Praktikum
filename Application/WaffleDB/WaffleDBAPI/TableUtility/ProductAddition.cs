namespace WaffleDB
{
    public class ProductAddition : IProduct, IAddition
    {
        //--- Product ------------------------------------
        public int idProduct { get; set; }
        public int idNuIn { get; set; }
        private float _price { get; set; }
        public float price
        {
            get { return (float)(_price * 1.19); }

            set { _price = value; }

        }
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
            _price = -1;
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
