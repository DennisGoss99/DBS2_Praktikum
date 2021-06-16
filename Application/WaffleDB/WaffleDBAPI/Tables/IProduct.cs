namespace WaffleDB
{
    public interface IProduct
    {
        int idProduct { get; set; }
        int idNuIn { get; set; }
        float price { get; set; }
        string name { get; set; }
    }
}
