using System;

namespace WaffleDB
{
    public class PersonalNotification
    {
        public int idNotification { get; set; }
        public int idStore { get; set; }
        public string message { get; set; }
        public string messageReason { get; set; }
        public int idIngredient { get; set; }
        public string ingredientName { get; set; }
        public DateTime time { get; set; }
    }
}
