public class EventTest
{
    private java.util.Vector data = new java.util.Vector();
    public synchronized void addMyTestListener(MyTestListener lis) {
        data.addElement(lis);
    }
    public synchronized void removeMyTestListener(MyTestListener lis) {
        data.removeElement(lis);
    }
    public interface MyTestListener extends java.util.EventListener {
        void testEvent(MyTestEvent event);
    }
    public class MyTestEvent extends java.util.EventObject {
        private static final long serialVersionUID = 1L;
        public float oldValue,newValue;        
        MyTestEvent(Object obj, float oldValue, float newValue) {
            super(obj);
            this.oldValue = oldValue;
            this.newValue = newValue;
        }
    }
    public void notifyMyTest() {
        java.util.Vector dataCopy;
        synchronized(this) {
            dataCopy = (java.util.Vector)data.clone();
        }
        for (int i=0; i< dataCopy.size(); i++) {
            MyTestEvent event = new MyTestEvent(this, 0, 1);
            ((MyTestListener)dataCopy.elementAt(i)).testEvent(event);
        }
    }
}