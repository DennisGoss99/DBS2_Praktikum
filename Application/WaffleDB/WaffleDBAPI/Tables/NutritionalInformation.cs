namespace WaffleDB
{
    public class NutritionalInformation : IDataBaseTable
    {
        public int idNuIn { get; set; }
        public float calories { get; set; }
        public float saturatedFat { get; set; }
        public float transFat { get; set; }
        public float carbohydrates { get; set; }
        public float sugar { get; set; }
        public float protein { get; set; }
        public float salt { get; set; }

        public NutritionalInformation() : this(0)
        {

        }

        public NutritionalInformation(int idNuIn) : this(idNuIn, 0, 0, 0, 0, 0, 0, 0)
        {

        }

        public NutritionalInformation(int idNuIn, float calories, float saturatedFat, float transFat, float carbohydrates, float sugar, float protein, float salt)
        {
            this.idNuIn = idNuIn;
            this.calories = calories;
            this.saturatedFat = saturatedFat;
            this.transFat = transFat;
            this.carbohydrates = carbohydrates;
            this.sugar = sugar;
            this.protein = protein;
            this.salt = salt;
        }

        public string TableName => "NutritionalInformation";
        public string UpdateCommand =>
             "UPDATE " + TableName + " SET " +
             "calories = " + calories + ", " +
             "saturatedFat = " + saturatedFat + ", " +
             "transFat = " + transFat + ", " +
             "carbohydrates = " + carbohydrates + ", " +
             "sugar = " + sugar + ", " +
             "protein = " + protein + ", " +
             "salt = " + salt +
             " WHERE idInventory = " + idNuIn;
        public string InsertCommand =>
            "INSERT INTO " + TableName +
            " VALUES(" +
            idNuIn + "," +
            calories + "," +
            saturatedFat + "," +
            transFat + "," +
            carbohydrates + "," +
            sugar + "," +
            protein + "," +
            salt +
            ")";
        public override string ToString()
        {
            return
                "<NutritionalInformation> idNuIn:" + idNuIn +
                " calories:" + calories +
                " saturatedFat:" + saturatedFat +
                " transFat:" + transFat +
                " carbohydrates:" + carbohydrates +
                " sugar:" + sugar +
                " protein:" + protein +
                " salt:" + salt;
        }
    }
}
