using System;

namespace WaffleDB
{
    public class Waffle : IDataBaseTable
    {
        public int idWaffle { get; set; }
        public string creatorName { get; set; }
        public DateTime creationDate { get; set; }
        public int processingTimeSec { get; set; }
        public string healty { get; set; }

        public Waffle() : this(-1, null, DateTime.Now, -1, null)
        {

        }

        public Waffle(int waffleID, string creatorName) : this(waffleID, creatorName, DateTime.Now, -1, null)
        {
   
        }

        public Waffle(int waffleID, string creatorName , DateTime creationDate , int processingTimeSec, string healty)
        {
            idWaffle = waffleID;
            this.creatorName = creatorName;
            this.creationDate = creationDate;
            this.processingTimeSec = processingTimeSec;
            this.healty = healty;
        }

        public string TableName => "Waffle";
        public string UpdateCommand => 
            "UPDATE " + TableName + " SET " +
            "creatorName = \"" + creatorName + "\", " +
            "creationDate = \"" + creationDate + "\", " +
            "processingTimeSec = " + processingTimeSec + ", " +
            "healty = \"" + healty + "\"" +
            " WHERE idWaffle = " + idWaffle;
        public string InsertCommand => 
            "INSERT INTO " + TableName + 
            " VALUES(" +
            idWaffle + "," +
           "\"" + creatorName + "\"," +
            "\"" + creationDate + "\"," +
            processingTimeSec + "," +
            "\"" + healty + "\"" +
            ")";


        public override string ToString()
        {
            return
            "idWaffle:" + idWaffle +
            " creatorName:" + creatorName +
            " creationDate:" + creationDate +
            " processingTimeSec:" + processingTimeSec +
            " healty:" + healty;
        }
    }
}
