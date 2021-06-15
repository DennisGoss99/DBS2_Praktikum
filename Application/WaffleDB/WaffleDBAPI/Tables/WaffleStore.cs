namespace WaffleDB
{
    public class WaffleStore : IDataBaseTable
    {
        public int idStore { get; set; }
        public string name { get; set; }
        public string areaCode { get; set; }
        public string location { get; set; }
        public string streetName { get; set; }
        public string houseNumber { get; set; }

        public string TableName => "WaffleStore";
        public string UpdateCommand =>
             "UPDATE " + TableName + " SET " +
             "name = \"" + name + "\"" +
             "areaCode = \"" + areaCode + "\"" +
             "location = \"" + location + "\"" +
             "streetName = \"" + streetName + "\"" +
             "houseNumber = \"" + houseNumber + "\"" +
             " WHERE idOrder = " + idStore;
        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idStore + "," +
            "\"" + name + "\"" + "," +
            "\"" + areaCode + "\"" + "," +
            "\"" + location + "\"" + "," +
            "\"" + streetName + "\"" + "," +
            "\"" + houseNumber + "\"" +
            ")";

        public override string ToString()
        {
            return
                "<WaffleStore> idStore:" + idStore +
                " name:" + name +
                " areaCode:" + areaCode +
                " location:" + location +
                " streetName:" + streetName +
                " houseNumber:" + houseNumber;
        }
    }
}
