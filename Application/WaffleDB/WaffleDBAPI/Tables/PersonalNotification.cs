using System;

namespace WaffleDB
{
    public class PersonalNotification : IDataBaseTable
    {
        public int idNotification { get; set; }
        public int idStore { get; set; }
        public string message { get; set; }
        public string messageReason { get; set; }
        public int idIngredient { get; set; }
        public string ingredientName { get; set; }
        public DateTime time { get; set; }

        public string TableName => "PersonalNotification";
        public string UpdateCommand =>
             "UPDATE " + TableName + " SET " +
             "message = \"" + message + "\", " +
             "messageReason = \"" + messageReason + "\", " +
             "idIngredient = " + idIngredient + ", " +
             "ingredientName = \"" + ingredientName + "\", " +
             "time = \"" + time + "\"" +
             " WHERE idInventory = " + idNotification +
             " AND idStore = " + idStore;
        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idNotification + "," +
            idStore + "," +
            message + "," +
            messageReason + "," +
            idIngredient + "," +
            ingredientName + "," +
            time +
            ")";
        public override string ToString()
        {
            return
                "<PersonalNotification> idNotification:" + idNotification +
                " idStore:" + idStore +
                " message:" + message +
                " messageReason:" + messageReason +
                " idIngredient:" + idIngredient +
                " ingredientName:" + ingredientName +
                " time:" + time;
        }
    }
}
