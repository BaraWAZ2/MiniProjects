 package networkingassignment;

import java.io.*;
import java.math.BigInteger;
import java.net.ServerSocket;
import java.net.Socket;

/**
 *
 * @author Bara Wazwaz
 */

public class Server {
    
    static final BigInteger zero;
    static final BigInteger one;
    static final BigInteger two;
    static {
        zero = new BigInteger("0");
        one  = new BigInteger("1");
        two  = new BigInteger("2");
    }
    
    private static BigInteger throwMe(String exceptionMessage) throws Exception {
        throw new Exception(exceptionMessage);
    }
    
    private static BigInteger power(BigInteger a, BigInteger b) {
        BigInteger ans = one;
        while (!b.equals(zero)) {
            if (b.mod(two).equals(one))
                ans = ans.multiply(a);
            a = a.multiply(a);
            b = b.divide(two);
        }
        return ans;
    }
    
    static String evaluate(String expression) {
        String[] parsed = expression.split(" ");
        if (parsed.length != 3) {
            return "Error : expression must hold 3 space-separated tokens";
        }
        
        BigInteger a, b;
        char operation;
        try {
            a = new BigInteger(parsed[0]);
            operation = parsed[1].charAt(0);
            b = new BigInteger(parsed[2]);
        }
        catch (NumberFormatException e) {
            return "Error : both sides of the operators must be an Integer";
        }
        
        if (parsed[1].length() != 1) {
            return "Error : 2nd token must be exactly one character long (the operation)";
        }
        
        if ((operation == '/' || operation == '%') && b.equals(zero)) {
            return "Result : Error : Division by zero";
        }
        
        BigInteger result;
        try {
            result = switch(operation) {
                case '+' -> a.add(b);
                case '-' -> a.subtract(b);
                case '*' -> a.multiply(b);
                case '/' -> a.divide(b);
                case '%' -> a.mod(b);
                case '^' -> power(a, b);
                default -> throwMe(operation + " is not an operator defined by this service");
            };
        }
        catch (Exception e) {
            return "Error : " + e.getMessage();
        }
        
        return String.valueOf("Result : " + result);
    }
    
    public static void main(String[] args) {
        final int portNumber = 12345;
        final String host = "localhost"; // alias for 127.0.0.1
        
        // Forming Connection/Handshake
        try (
            ServerSocket serverSocket = new ServerSocket(portNumber);
            Socket socket = serverSocket.accept();
        ) {
            
            // IO Coupling
            try (
                BufferedReader serverInput = new BufferedReader(
                    new InputStreamReader(socket.getInputStream())
                );
                PrintWriter serverOutput = new PrintWriter(
                    new OutputStreamWriter(socket.getOutputStream()), 
                    true // auto flush
                );
            ) {
                
                // Confirming Successful Connection
                System.out.println("Server started at " + host + ":" + portNumber);
                System.out.println("Connected by (" + socket.getRemoteSocketAddress() + ")");

                // Exchange
                String messageReceived = serverInput.readLine();
                while (!messageReceived.trim().equalsIgnoreCase("quit")) {
                    String messageSent = evaluate(messageReceived);
                    serverOutput.println(messageSent);
                    messageReceived = serverInput.readLine();
                }
                serverOutput.println();
            }
            catch (IOException e) {
                System.out.println("An issue has occurred while creating the IO Coupling");
                System.out.println("Error Message : " + e.getMessage());
            }
        }
        catch(IOException e) {
            System.out.println("An issue has occurred while forming the Forming Connection/Handshake");
            System.out.println("Error Message : " + e.getMessage());
        }
    }
}
