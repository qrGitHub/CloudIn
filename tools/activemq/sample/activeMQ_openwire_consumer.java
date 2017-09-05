import javax.jms.Connection;
import javax.jms.ConnectionFactory;
import javax.jms.Destination;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.Session;

import org.apache.activemq.ActiveMQConnectionFactory;

import javax.jms.MessageListener;
import javax.jms.JMSException;
import javax.jms.TextMessage;

public final class activeMQ_openwire_consumer {
    private static String user = "qr_admin";
    private static String password = "1qaz2wsx$RFV";
    private static String uri = "tcp://localhost:61616";

    public static void main(final String[] args) throws Exception {
        final ConnectionFactory connFactory = new ActiveMQConnectionFactory(user, password, uri);
        final Connection conn = connFactory.createConnection();
        conn.start();

        //final Session sess = conn.createSession(true, Session.AUTO_ACKNOWLEDGE);
        final Session sess = conn.createSession(false, Session.CLIENT_ACKNOWLEDGE);
        final Destination dest = sess.createQueue("qr_test");
        final MessageConsumer consumer = sess.createConsumer(dest);

        //consumer.setMessageListener(new MessageListener() {
        //    @Override
        //    public void onMessage(Message message) {
        //        try {
        //            TextMessage textMessage = (TextMessage)message;
        //            System.out.println(textMessage.getText());
        //        } catch (JMSException e) {
        //            e.printStackTrace();
        //        }

        //        try {
        //            sess.commit();
        //        } catch (JMSException e) {
        //            e.printStackTrace();
        //        }
        //    }
        //});

        Message message = consumer.receive();
        TextMessage textMessage = (TextMessage)message;
        System.out.println(textMessage.getText());
        //message.acknowledge();  //Session.AUTO_ACKNOWLEDGE时，默认自动发送确认消息
            
        consumer.close();
        sess.close();
        conn.close();
    }
}
