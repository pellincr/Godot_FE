extends Node
##
# Store constants used in unit based datatypes
##

const LOW_STAT_LEVEL_BAR := 2
const HIGH_STAT_LEVEL_BAR := 7
const LOW_HEALTH_STAT_LEVEL_BAR := 10
const HIGH_HEALTH_STAT_LEVEL_BAR := 18


#Unit Family determines a unit's promotion options and class skill pool
enum FAMILY 
{ ## TO BE IDEATED MORE CLASSES REFERENCE SPREAD SHEET
	ARMOR_KNIGHT,
	CAVALRY,
	SWORDSMAN,
	RANGER,
	PRIATE,
	THIEF,
	HEALER,
	ORC
}

enum FACTION 
{ ## TO BE IDEATED MORE CLASSES REFERENCE SPREAD SHEET
	MERCENARY,
	KINGDOM,
	THEOCRACY,
	LAWBREAKERS,
	CULTIST,
	SKELETAL,
	MONSTER
}

enum TRAITS 
{ ## Unique information for specific unit
	ARMORED,
	MOUNTED,
	FLIER,
	TERROR
}

enum movement_type 
{ ## How unit terrain traversal is calculated
	DEFAULT,
	HEAVY,
	MOBILE,
	MOUNTED,
	FLIER
}


## NAME BANKS
enum NAME_GENDERS 
{
	MALE,
	FEMALE,
}
var MALE_NAME_BANK = [
	"Craig", "Devin", "Jacob", "Porter", "Jarry", "Bogdan", "Masonar", "Jax",
	"Aarall", "Acanos", "Acarnar", "Addin", "Adius", "Alar", "Alaril", "Alasar",
	"Aldas", "Aler", "Alerin", "Alesan", "Aliamer", "Alveler", "Amar", "Amarid",
	"Ampeto", "Ancar", "Ando", "Anos", "Aranar", "Aranil", "Ardey", "Arel",
	"Aren", "Arenan", "Arinik", "Arogar", "Aron", "Arosar", "Aruz", "Asoniri",
	"Aurin", "Auseri", "Avaran", "Aven", "Avialar", "Baen", "Balar", "Balas",
	"Baliar", "Balic", "Balog", "Baltar", "Balyn", "Bandan", "Banill", "Banin",
	"Barbarto", "Baren", "Barro", "Baselan", "Baynar", "Bazar", "Belar", "Belix",
	"Bengo", "Benik", "Beniko", "Benin", "Berand", "Beranti", "Bergoan", "Besar",
	"Bestel", "Betton", "Beust", "Bolegro", "Boral", "Borst", "Bosovan", "Brannon",
	"Brir", "Cadryn", "Cail", "Camin", "Caminis", "Caniso", "Cariso", "Caros",
	"Carst", "Carth", "Casalor", "Cashar", "Casso", "Cason", "Cavar", "Celan",
	"Celas", "Celicu", "Cenos", "Ceretel", "Cerian", "Chaen", "Chakin", "Chanus",
	"Charane", "Chaun", "Cheth", "Chevute", "Cilin", "Corus", "Cusambe", "Daelas",
	"Dalar", "Dalen", "Danius", "Daric", "Darit", "Darril", "Dason", "Daus",
	"Derin", "Dier", "Dinel", "Dorin", "Dornet", "Doshand", "Doson", "Dushan",
	"Dusor", "Einar", "Elian", "Eliar", "Elic", "Elinus", "Emar", "Emonani",
	"Erik", "Erinak", "Erivu", "Erko", "Erlidan", "Esarn", "Estel", "Evut", "Ewal",
	"Facan", "Falal", "Fandar", "Farar", "Faril", "Faros", "Favan", "Favus",
	"Fawlre", "Fenaran", "Fendor", "Ferius", "Ferrido", "Findi", "Galarel",
	"Galban", "Galic", "Ganar", "Ganil", "Ganiv", "Ganyl", "Garath", "Garer",
	"Garesk", "Garin", "Garius", "Garus", "Gasto", "Gerikos", "Ginel", "Gorall",
	"Grale", "Granar", "Grart", "Grauxe", "Grifen", "Grik", "Grinos", "Griss",
	"Gunar", "Hadar", "Hadariar", "Haeran", "Hahius", "Handar", "Handis", "Hano",
	"Hanthu", "Harias", "Haric", "Haril", "Harir", "Hars", "Harth", "Hasolar",
	"Hastt", "Helav", "Helik", "Henir", "Hesken", "Hest", "Hestel", "Hettoneri",
	"Holaus", "Honte", "Horel", "Horrin", "Hukalo", "Hus", "Illan", "Illar",
	"Irga", "Irnaz", "Isar", "Ishton", "Iskin", "Ister", "Isterd", "Istev",
	"Jacaden", "Jalaras", "Jaliuli", "Jangan", "Janius", "Janyno", "Jaris", "Jarte",
	"Jase", "Javer", "Jonan", "Jondi", "Jonel", "Jonfi", "Jonic", "Jons", "Jorar",
	"Jorel", "Joren", "Joric", "Jorin", "Jorint", "Josha", "Josto", "Kalonen",
	"Kamar", "Kanaran", "Kano", "Karedan", "Kareg", "Karin", "Kedin", "Kelar",
	"Kelin", "Kenar", "Kerdic", "Kerid", "Kobet", "Kric", "Laeric", "Lanan",
	"Lanar", "Lanic", "Lankaur", "Lanust", "Lar", "Laras", "Larel", "Larnus",
	"Leau", "Lenax", "Lerte", "Leshof", "Lestous", "Liarol", "Linaus", "Llanos",
	"Llaris", "Llorinar", "Lolas", "Lorker", "Lorro", "Lorson", "Luil", "Lukis",
	"Lukovi", "Luron", "Luso", "Luto", "Madil", "Maisel", "Malar", "Malin",
	"Manak", "Manc", "Maniard", "Mano", "Manuss", "Maral", "Mararo", "Marid",
	"Maron", "Marton", "Masel", "Mauni", "Maus", "Mautis", "Medeiro", "Menam",
	"Merga", "Meson", "Meteri", "Meyr", "Minerde", "Mirar", "Moguret", "Monan",
	"Mongar", "Morill", "Morrder", "Mueron", "Mukiar", "Munic", "Muraris", "Muren",
	"Murossi", "Muschu", "Musor", "Myanero", "Mykeron", "Myr", "Nabail", "Nalow",
	"Nedan", "Neric", "Nerin", "Neronir", "Nesar", "Neyn", "Nich", "Odiam", "Olazar",
	"Olin", "Olstall", "Orori", "Oryn", "Osale", "Osando", "Osar", "Pahus",
	"Palik", "Parano", "Pardo", "Pasil", "Pasth", "Penyn", "Periar", "Perin",
	"Petas", "Peyrnu", "Praiso", "Rabalo", "Ralian", "Ralich", "Ramar", "Ramosen",
	"Ranen", "Raros", "Rars", "Rarzar", "Rellaron", "Restone", "Rinan", "Rinergan",
	"Rinian", "Rogar", "Roich", "Rokon", "Rolan", "Ronen", "Roraff", "Rorich",
	"Rosar", "Roschi", "Rumert", "Russh", "Rusthe", "Savar", "Sedas", "Selar",
	"Selian", "Senan", "Senaro", "Senten", "Serar", "Serel", "Seren", "Serian",
	"Setari", "Setoni", "Shan", "Shero", "Shir", "Shorik", "Sigak", "Silison",
	"Silus", "Sinad", "Sindalar", "Sinolax", "Sinov", "Sisar", "Stamma", "Stanid",
	"Stardan", "Stelo", "Stelos", "Stenfon", "Sterba", "Sterian", "Steris", "Stero",
	"Stolan", "Ston", "Stoss", "Sturo", "Svar", "Syavan", "Talian", "Tanant",
	"Tannto", "Taras", "Tasal", "Tasho", "Tasoe", "Taston", "Tavid", "Telar",
	"Telian", "Telif", "Terin", "Tetan", "Teutani", "Thamar", "Tharen", "Thargo",
	"Thasar", "Thato", "Thauin", "Thave", "Theren", "Tho", "Thogar", "Thond",
	"Thorlin", "Togar", "Tonen", "Toninus", "Tontus", "Torik", "Torok", "Treg",
	"Tress", "Trius", "Tunis", "Valarlit", "Valich", "Vanil", "Vanyan", "Varas",
	"Varin", "Varit", "Varta", "Vasan", "Vashtus", "Vayn", "Vazan", "Veres",
	"Verngen", "Veron", "Veyn", "Vezos", "Vien", "Vinensk", "Vinian", "Vinus",
	"Viopal", "Virone", "Vius", "Vivar", "Viviric", "Voracas", "Waron", "Windolen",
	"Winso", "Wylion", "Yogor", "Zaal", "Seron", "Raliar", "Valaras"
]

var FEMALE_NAME_BANK = [
	"Abiala", "Adali", "Adari", "Adarore", "Aderiel", "Agrae", "Aitese", "Alane",
	"Alia", "Aliani", "Alina", "Alisa", "Aloria", "Alys", "Ambeya", "Amendi",
	"Amera", "Amina", "Anasesh", "Anila", "Arokena", "Arra", "Asela", "Avala",
	"Bania", "Barisla", "Bele", "Beti", "Bonda", "Bora", "Broda", "Bynta", "Calari",
	"Calia", "Calica", "Calinila", "Camedna", "Caneleyr", "Canseri", "Canzess",
	"Cara", "Caresal", "Carike", "Cariri", "Carriva", "Ceria", "Cesenia", "Ceshariv",
	"Chaliar", "Chana", "Chardina", "Chari", "Chayni", "Chele", "Cherin", "Chona",
	"Chtene", "Ciana", "Cindali", "Ciusi", "Daela", "Dameta", "Danari", "Dandiau",
	"Danereti", "Danica", "Dara", "Dona", "Doni", "Donila", "Edda", "Edanda",
	"Elamah", "Elanda", "Elanine", "Elarin", "Elarivi", "Elini", "Ellera", "Ellia",
	"Elosene", "Elsi", "Emedea", "Eminial", "Erevi", "Fana", "Fanau", "Fara",
	"Farele", "Farini", "Fauane", "Felani", "Fenki", "Fera", "Feria", "Ferza",
	"Findi", "Galani", "Gausa", "Genia", "Genna", "Gensha", "Griane", "Griele",
	"Gushani", "Halda", "Hali", "Hanan", "Hareta", "Hari", "Harta", "Hauri",
	"Havani", "Hayl", "Helia", "Heyki", "Idara", "Idele", "Iseli", "Isonda",
	"Istoria", "Jala", "Jalerta", "Jalir", "Jareta", "Jasaveri", "Jauna", "Jelamia",
	"Jogdali", "Jonania", "Jorona", "Kaiella", "Karina", "Kenisa", "Kerai", "Kleri",
	"Kynara", "Kynersa", "Lali", "Lana", "Laria", "Larla", "Lela", "Lelina",
	"Lenasa", "Linia", "Lonara", "Loneri", "Loria", "Luicha", "Lurinea", "Lushani",
	"Lyna", "Mala", "Maisa", "Mamesi", "Marya", "Mayssa", "Melle", "Merinis",
	"Meriu", "Modera", "Murossi", "Nelel", "Nellin", "Neni", "Nereya", "Nerissar",
	"Netha", "Nullera", "Nuschari", "Olena", "Palia", "Parea", "Parichi", "Pela",
	"Pelari", "Phera", "Phina", "Runia", "Rusana", "Rusha", "Saba", "Saesh",
	"Salani", "Sanar", "Sanelita", "Saninar", "Sanza", "Sarene", "Sarici", "Sarina",
	"Sarori", "Sasena", "Scena", "Selia", "Selin", "Sella", "Senova", "Serena",
	"Serica", "Serine", "Serondala", "Serreri", "Setena", "Seynara", "Shana",
	"Shani", "Shannet", "Shosa", "Siadi", "Siale", "Siari", "Sideni", "Sisella",
	"Solia", "Spella", "Stila", "Stena", "Stenera", "Steni", "Stenia", "Sulare",
	"Svela", "Syala", "Sysan", "Tahlis", "Tala", "Talia", "Tela", "Telari",
	"Teline", "Tenana", "Tenasa", "Tendra", "Thenia", "Thala", "Thale", "Thalia",
	"Tharanie", "Thina", "Tusha", "Urilla", "Vaneta", "Vani", "Vanicha", "Varia",
	"Vasela", "Vasinin", "Vela", "Verana", "Viera", "Vitaloa", "Werana", "Wesa",
	"Weyri", "Wimina", "Winiba", "Zarena", "Ziali", "Zira", "Lunella", "Dushani",
    "Yari"
]

var UNISEX_NAME_BANK = [
	"Aela",
	"Aleron",
	"Arel",
	"Arin",
	"Aris",
	"Avian",
	"Avialar",
	"Brin",
	"Caelen",
	"Caurio",
	"Cevau",
	"Dagni",
	"Darian",
	"Darin",
	"Eris",
	"Eska",
	"Estel",
	"Faelan",
	"Gael",
	"Hale",
	"Haregen",
	"Iri",
	"Isar",
	"Jalen",
	"Jari",
	"Kiran",
	"Korin",
	"Lior",
	"Loras",
	"Lumi",
	"Maisel",
	"Mani",
	"Meriu",
	"Mirae",
	"Myr",
	"Neri",
	"Osar",
	"Rian",
	"Riven",
	"Selar",
	"Seren",
	"Tereal",
	"Viusoni",
	"Wari",
    "Yari"
]
