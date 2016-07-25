import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Created by TsaiKunYu on 27/02/16.
 */
public class Finlay {
    // Machine Settings
    public static final int codCookLength = 80;
    public static final int hadCookLength = 90;
    public static final int chipsCookLength = 120;

    public static final int fishSlots = 4;
    public static final int chipsSlots = 4;
    public static final int maxCustomerWaitingSecs = 600;
    public static final int withinMaxCookedSecs = 120;
    // End Machine Settings

    private static final SimpleDateFormat simpleDateFormat = new SimpleDateFormat("hh:mm:ss");
    public static final int maxChipsRound = maxCookRoundWithinSecs(chipsCookLength, withinMaxCookedSecs);
    public static final int maxFishRound = maxCookRoundWithinSecs(codCookLength < hadCookLength ? codCookLength : hadCookLength, withinMaxCookedSecs);

    public static void main(String[] args) {
        List<Order> orderList = collectOrderFromInput();

        // process order
        for (int i = 0; i < orderList.size(); i++) {
            Order order = orderList.get(i);
            StringBuilder stringBuilder = new StringBuilder("at " + simpleDateFormat.format(order.orderCal.getTime()) + ", " + "Order #" + order.orderNumber);
            if (isExceedMaxRound(order) || isCustomerWillWaitTooLong(order)) {
                System.out.println(stringBuilder.append(" Rejected"));
            } else {
                System.out.println(stringBuilder.append(" Accepted"));
                handleOrder(order);
            }
        }
    }

    /*
    Order #1, 12:00:00, 2 Cod, 4 Haddock, 3 Chips
    Order #2, 12:00:30, 2 Cod, 2 Chips
    Order #3, 12:02:00, 2 Cod, 5 Haddock
    Order #4, 12:04:00, 21 Chips

    Order #1, 12:00:00, 2 Cod, 4 Haddock, 3 Chips
    Order #2, 12:00:30, 1 Haddock, 1 Chips
    Order #3, 12:01:00, 21 Chips
     */
    public static Order transferInputToOrder(String input){
        Order order = new Order();
        input = input.replace(" ","");
        String lines[] = input.split(",");
        for( String partInput : lines){

            if( partInput.contains("Cod")){
                partInput = partInput.replace("Cod","");
                order.codNum = Integer.parseInt(partInput);
                continue;
            }

            if( partInput.contains("Haddock")){
                partInput = partInput.replace("Haddock","");
                order.hadNum = Integer.parseInt(partInput);
                continue;
            }

            if( partInput.contains("Chips")){
                partInput = partInput.replace("Chips","");
                order.chipsNum = Integer.parseInt(partInput);
                continue;
            }

            if( partInput.contains("Order")){
                partInput = partInput.replace("Order#","");
                order.orderNumber = Integer.parseInt(partInput);
                continue;
            }

            try {
//                System.out.println("date = " + partInput);
                Date date = simpleDateFormat.parse(partInput);
                order.orderCal.setTime(date);
            } catch (ParseException e) {
                continue;
            }

        }
        return order;
    }

    public static List<Order> collectOrderFromInput(){
        Scanner in = new Scanner(System.in);
        List<Order> orderList = new ArrayList<Order>();
        List<String> orderStrList = new ArrayList<String>();

        System.out.println("Please input your order and append additional line with \"DONE\" after your last line.");

        while(in.hasNextLine()){
            String next = in.nextLine();
            if( next.toUpperCase().equals("DONE"))
                break;
            orderList.add(transferInputToOrder(next));
        }

        for( String input : orderStrList){
            Order order = transferInputToOrder(input);
            orderList.add(order);
        }

        return orderList;
    }

    public static void handleOrder(Order order) {

        // Get Min Require Time
        int minFishTime = minFishTime(order.codNum, order.hadNum);
        int minChipsTime = minChipsTime(order.chipsNum);
        int minRequireTime = getMax(minFishTime, minChipsTime);

        // Input all the request into map
        Order.inputChipsRequest(order.requestMap, chipsCookLength, minRequireTime, order.chipsNum);
        Order.inputFishRequest(order.requestMap, minFishTime, minRequireTime, order.codNum, order.hadNum);

        // To show the map request in time order.
        List<Integer> sortedKeyList = getMapSortedKeyList(order.requestMap);
        for (Integer timeOffSet : sortedKeyList) {
            InputPortion input = order.requestMap.get(timeOffSet);
            Calendar offSetCal = getSecsOffSetCalendar(order.actualStartCal, timeOffSet);
            printConsole(offSetCal.getTime(), input);
        }
        printServe(order);
    }

    public static Calendar getSecsOffSetCalendar(Calendar actualStartCal, int secs) {
        Calendar requestCal = Calendar.getInstance();
        requestCal.setTime(actualStartCal.getTime());
        requestCal.add(Calendar.SECOND, secs);
        return requestCal;
    }

    public static Boolean isExceedMaxRound(Order order) {
        int chipsCookRequireRound = divideRoundUp(order.chipsNum, chipsSlots);

        int totalFishNum = order.codNum + order.hadNum;
        int fishCookRequireRound = divideRoundUp(totalFishNum, fishSlots);
        if (chipsCookRequireRound > maxChipsRound || fishCookRequireRound > maxFishRound) {
            return true;
        }

        return false;
    }

    public static List<Integer> getMapSortedKeyList(HashMap<Integer, InputPortion> map) {
        List<Integer> sortedKeyList = new ArrayList(map.keySet());
        Collections.sort(sortedKeyList);
        return sortedKeyList;
    }

    public static void addRequestToMap(HashMap<Integer, InputPortion> map, int time, InputPortion inputPortion) {
        if (map.containsKey(time)) {
            map.get(time).addPortion(inputPortion);
        } else {
            map.put(time, inputPortion);
        }
    }

    public static Boolean isCustomerWillWaitTooLong(Order order) {
        order.setChipsRequireTime(minChipsTime(order.chipsNum));
        order.setFishRequireTime(minFishTime(order.codNum, order.hadNum));
        order.updateCookingTime();

        if (Order.previousEndTime != null && order.orderCal.before(Order.previousEndTime)) {
            int offsetInSec = secsBetweenCal(order.orderCal, Order.previousEndTime);
            order.actualStartCal.setTime(order.orderCal.getTime());
            order.actualStartCal.add(Calendar.SECOND, offsetInSec);
        } else {
            order.actualStartCal.setTime(order.orderCal.getTime());
        }

        order.endCal.setTime(order.actualStartCal.getTime());
        order.endCal.add(Calendar.SECOND, order.getCookingTime());
        order.setCustomerWaitSecs(secsBetweenCal(order.orderCal, order.endCal));

        if (order.getCustomerWaitSecs() > maxCustomerWaitingSecs) {
            return true;
        } else {
            Order.previousEndTime = order.endCal;
            return false;
        }
    }

    public static int recurFishTime(int codNum, int hadNum, int round, int possibleMinTime, int remainSlots) {
        int time = 0;

        int totalNum = codNum + hadNum;

        if (totalNum <= remainSlots) {
            return getMax(possibleMinTime, getMax(
                    codNum > 0 ? codCookLength : 0,
                    hadNum > 0 ? hadCookLength : 0));
        }

        // If we put all cods into slot
        int fullCodSlot = codNum > 0 ? divideRoundUp(codNum, round) : 0;

        // The remainAvailableSlots we have to cook haddock
        int availableSlot = remainSlots - fullCodSlot;

        if (hadNum > 0 && codNum > 0 && hadNum > availableSlot * (round - 1)) {
            codNum = codNum - 1;
            hadNum = hadNum - 1;
            time = codCookLength + hadCookLength;
        }
        else if (codNum >= round) {
            codNum = codNum - round;
            time = codCookLength * round;
        }
        else if (codNum > 0 && hadNum > 0) {
            codNum = codNum - 1;
            hadNum = hadNum - 1;
            time = codCookLength + hadCookLength;
        }
        else if (hadNum >= round) {
            hadNum = hadNum - round;
            time = hadCookLength * round;
        }

        possibleMinTime = getMax(possibleMinTime, time);
        remainSlots--;
        if (remainSlots > 0) {
            return recurFishTime(codNum, hadNum, round, possibleMinTime, remainSlots);
        }

        return possibleMinTime;
    }

    public static int minChipsTime(int chipsPortion) {
        if (chipsPortion == 0) {
            return 0;
        }

        return chipsCookLength * (divideRoundUp(chipsPortion, chipsSlots));
    }

    public static int minFishTime(int codNum, int hadNum) {
        int total = codNum + hadNum;
        int requireRound = divideRoundUp(total, fishSlots);
        int minTime = -1;

        minTime = recurFishTime(codNum, hadNum, requireRound, 0, fishSlots);
        return minTime;
    }

    public static int divideRoundUp(int dividend, int divider) {
        if (dividend == 0)
            return 0;

        return (dividend % divider) > 0 ? (dividend / divider) + 1 : dividend / divider;

    }

    public static int getMax(int a, int b) {
        return (a > b) ? a : b;
    }

    public static int getMin(int a, int b) {
        return (a < b) ? a : b;
    }

    public static int maxCookRoundWithinSecs(int cookTime, int withinSecs) {
        /*
         1. at least can cook one round.
         2. after first round, how many rounds we can still cook.
          */
        int availRound = (withinSecs / cookTime) + 1;
//        System.out.println("available times = " + availRound);

        return availRound;
    }

    public static int secsBetweenCal(Calendar prev, Calendar after) {
        return (int) (after.getTimeInMillis() - prev.getTimeInMillis()) / 1000;
    }


    public static void printServe(Order order) {
        System.out.println("at " + simpleDateFormat.format(order.endCal.getTime()) + ", Serve Order #" + order.orderNumber);
    }

    public static void printConsole(Date time, InputPortion inputPortion) {
        StringBuilder stringBuilder = new StringBuilder("at " + simpleDateFormat.format(time) + ", Begin Cooking ");
        if(inputPortion.codNum>0){
            stringBuilder.append(inputPortion.codNum + " Cod ");
        }else if( inputPortion.hadNum > 0 ){
            stringBuilder.append(inputPortion.hadNum + " Haddock ");
        }else if( inputPortion.chipsNum > 0 ){
            stringBuilder.append(inputPortion.chipsNum + " Chips");
        }

        System.out.println(stringBuilder.toString());
    }

    public static class Order {
        public int orderNumber;
        public static Calendar previousEndTime = null;
        public int codNum;
        public int hadNum;
        public int chipsNum;

        private int reqCookingTime;
        private Calendar orderCal;
        private Calendar actualStartCal;
        private Calendar endCal;
        private int customerWaitSecs;
        private int fishRequireTime;
        private int chipsRequireTime;

        private HashMap<Integer, InputPortion> requestMap = new HashMap<Integer, InputPortion>();

        public Order() {
            orderCal = Calendar.getInstance();
            endCal = Calendar.getInstance();
            actualStartCal = Calendar.getInstance();
        }

        public Order(int hour, int min, int sec, int codNum, int hadNum, int chipsNum) {
            orderCal = Calendar.getInstance();
            orderCal.set(Calendar.HOUR_OF_DAY, hour);
            orderCal.set(Calendar.MINUTE, min);
            orderCal.set(Calendar.SECOND, sec);

            endCal = Calendar.getInstance();
            actualStartCal = Calendar.getInstance();

            this.codNum = codNum;
            this.hadNum = hadNum;
            this.chipsNum = chipsNum;
        }

        public static void inputChipsRequest(HashMap<Integer, InputPortion> inputRequest, int chipsTimeUsage, int totalTimeUsage, int chipsNum) {
            int round = 1;
            while (chipsNum > 0) {
                int putChipsNum = chipsNum > chipsSlots ? chipsSlots : chipsNum;
                chipsNum -= putChipsNum;
                addRequestToMap(inputRequest, totalTimeUsage - chipsTimeUsage * round, new InputPortion(0, 0, putChipsNum));
                round++;
            }
        }

        public static void inputFishRequest(HashMap<Integer, InputPortion> inputRequest, int fishTimeUsage, int totalTimeUsage, int orderCodNum, int orderHadNum) {

            if (fishTimeUsage == codCookLength) {
                addRequestToMap(inputRequest, totalTimeUsage - codCookLength, new InputPortion(orderCodNum, 0, 0));
            } else if (fishTimeUsage == hadCookLength) {
                addRequestToMap(inputRequest, totalTimeUsage - hadCookLength, new InputPortion(0, orderHadNum, 0));
                if (orderCodNum > 0)
                    addRequestToMap(inputRequest, totalTimeUsage - codCookLength, new InputPortion(orderCodNum, 0, 0));
            } else if (fishTimeUsage == codCookLength * maxFishRound) {
            /*
                only CC in a slot, no CH/HH
                which means H will be placed in a slot individually
             */
                int endRoundCodNum = fishSlots - orderHadNum;
                int firstRoundCodNum = orderCodNum - endRoundCodNum;
                addRequestToMap(inputRequest, totalTimeUsage - fishTimeUsage, new InputPortion(firstRoundCodNum, 0, 0));
                addRequestToMap(inputRequest, totalTimeUsage - hadCookLength, new InputPortion(0, orderHadNum, 0));
                addRequestToMap(inputRequest, totalTimeUsage - codCookLength, new InputPortion(endRoundCodNum, 0, 0));
            } else if (fishTimeUsage == (codCookLength + hadCookLength)) {
            /*
             try to put all cod at last round, leave had at first round
             but not all first round will be full of had
              */
                int endRoundHadNum = (fishSlots - orderCodNum) > 0 ? (fishSlots - orderCodNum) : 0;
                int firstRoundHadNum = orderHadNum - endRoundHadNum;
                int endRoundCodNum = fishSlots - endRoundHadNum;

                addRequestToMap(inputRequest, totalTimeUsage - fishTimeUsage, new InputPortion(0, firstRoundHadNum, 0));

                int firstPutCod = orderCodNum - endRoundCodNum;
                if (firstPutCod > 0) {
                    addRequestToMap(inputRequest, totalTimeUsage - fishTimeUsage, new InputPortion(firstPutCod, 0, 0));
                }

                if (endRoundHadNum > 0) {
                    addRequestToMap(inputRequest, totalTimeUsage - hadCookLength, new InputPortion(0, endRoundHadNum, 0));
                }

                if (endRoundCodNum > 0) {
                    addRequestToMap(inputRequest, totalTimeUsage - codCookLength, new InputPortion(endRoundCodNum, 0, 0));
                }

            } else if (fishTimeUsage == hadCookLength * maxFishRound) {
            /*
             first round slots are all had
             last round put cod & had
             use up all cod for last round
             */
                int firstRoundHadNum = fishSlots;
                int endRoundHadNum = fishSlots - orderCodNum;

                int hadPutAtZeroSecs = firstRoundHadNum - orderCodNum;
                int hadPutAfterInterval = orderCodNum;
                addRequestToMap(inputRequest, totalTimeUsage - codCookLength, new InputPortion(orderCodNum, 0, 0));
                addRequestToMap(inputRequest, totalTimeUsage - hadCookLength, new InputPortion(0, endRoundHadNum, 0));
                addRequestToMap(inputRequest, totalTimeUsage - fishTimeUsage + (hadCookLength - codCookLength), new InputPortion(0, hadPutAfterInterval, 0));
                addRequestToMap(inputRequest, totalTimeUsage - fishTimeUsage, new InputPortion(0, hadPutAtZeroSecs, 0));
            }
        }

        public int getFishRequireTime() {
            return fishRequireTime;
        }

        public void setFishRequireTime(int fishRequireTime) {
            this.fishRequireTime = fishRequireTime;
        }

        public int getChipsRequireTime() {
            return chipsRequireTime;
        }

        public void setChipsRequireTime(int chipsRequireTime) {
            this.chipsRequireTime = chipsRequireTime;
        }

        public int getCustomerWaitSecs() {
            return customerWaitSecs;
        }

        public void setCustomerWaitSecs(int customerWaitSecs) {
            this.customerWaitSecs = customerWaitSecs;
        }

        public String getInfo() {
            return simpleDateFormat.format(orderCal.getTime()) + ", " + codNum + " Cod, " + hadNum + " Haddock, " + chipsNum + " Chips";
        }

        public String getDetailInfo() {
            return "Order receive: " + simpleDateFormat.format(orderCal.getTime()) + ", " + codNum + " Cod, " + hadNum + " Haddock, " + chipsNum + " Chips"
                    + "\nCooking Time: " + getCookingTime()
                    + "\nActual launch: " + simpleDateFormat.format(actualStartCal.getTime())
                    + "\nEnd at: " + simpleDateFormat.format(endCal.getTime())
                    + "\nCustomer wait for " + getCustomerWaitSecs() + " secs";
        }


        public void updateCookingTime() {
            reqCookingTime = getMax(chipsRequireTime, fishRequireTime);
        }

        public void setCookingTime(int reqCookingTime) {
            this.reqCookingTime = reqCookingTime;
        }

        public int getCookingTime() {
            return reqCookingTime;
        }
    }

    public static class InputPortion {
        private int codNum = 0;
        private int hadNum = 0;
        private int chipsNum = 0;

        public InputPortion(int codNum, int hadNum, int chipsNum) {
            this.codNum = codNum;
            this.hadNum = hadNum;
            this.chipsNum = chipsNum;
        }

        public void addPortion(InputPortion inputPortion) {
            codNum += inputPortion.getCodNum();
            hadNum += inputPortion.getHadNum();
            chipsNum += inputPortion.getChipsNum();
        }

        public int getCodNum() {
            return codNum;
        }

        public void setCodNum(int codNum) {
            this.codNum = codNum;
        }

        public int getHadNum() {
            return hadNum;
        }

        public void setHadNum(int hadNum) {
            this.hadNum = hadNum;
        }

        public int getChipsNum() {
            return chipsNum;
        }

        public void setChipsNum(int chipsNum) {
            this.chipsNum = chipsNum;
        }
    }
}

//Obj C

NSString * line = readLine();
NSArray* lines  =  [line componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
printLine([lines objectAtIndex:0]);
}

