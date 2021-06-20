namespace WaffleDB
{
    public interface IIngredient
    {
        int canPutOnWaffle { get; set; }
        int idIngredient { get; set; }
        int idNuIn { get; set; }
        string name { get; set; }
        float price { get; set; }
        int processingTimeSec { get; set; }
        string unit { get; set; }
    }
}