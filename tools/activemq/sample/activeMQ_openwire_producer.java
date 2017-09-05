import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.Destination;
import javax.jms.Message;
import javax.jms.MessageProducer;
import javax.jms.Session;
 
import org.apache.activemq.ActiveMQConnectionFactory;
 
public final class activeMQ_openwire_producer {
    private static String user = "qr_admin";
    private static String password = "1qaz2wsx$RFV";
    private static String uri = "tcp://localhost:61616";

    public static void main(final String[] args) throws Exception {
        final ConnectionFactory connFactory = new ActiveMQConnectionFactory(user, password, uri);
        final Connection conn = connFactory.createConnection();
        final Session sess = conn.createSession(false, Session.AUTO_ACKNOWLEDGE);
        final Destination dest = sess.createQueue("qr_test");
        final MessageProducer prod = sess.createProducer(dest);
   
        String str = "";
        if (args.length == 0) {
            str = "Hello ActiveMQ";
        } else {
            str = args[0];
            for (int i = 1; i < args.length; i++) {
                str += " " + args[i];
            }
        }
        final Message msg = sess.createTextMessage(str);
        prod.send(msg);

        conn.close();
    }
}
