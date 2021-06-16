using System;

namespace WaffleDB
{
    public interface IWaffle
    {
        int idWaffle { get; set; }
        string creatorName { get; set; }
        DateTime creationDate { get; set; }
        int processingTimeSec { get; set; }
        string healty { get; set; }
    }
}
