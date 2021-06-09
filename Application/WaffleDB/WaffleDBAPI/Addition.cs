namespace WaffleDB
{
    public class Addition
    {
        public int idAddition { get; set; }
        public string optComment { get; set; }

        public Addition() : this(-1, null)
        {

        }

        public Addition(int idAddition, string optComment)
        {
            this.idAddition = idAddition;
            this.optComment = optComment;
        }

        public string TableName => "Addition";
        public string UpdateCommand =>
            "UPDATE " + TableName +
            " SET optComment = \"" + optComment + "\"" +
            " WHERE idAddition = " + idAddition;

        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idAddition + "," +
             "\"" + optComment + "\"" +
            ")";
    }
}
