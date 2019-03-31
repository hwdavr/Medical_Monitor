template <class T>
util_list<T>::util_list(deleter pDeleter): mHead(NULL), mTail(NULL),
	mDeleter(pDeleter) {}

template <class T>
util_list<T>::~util_list() {
	clear(mDeleter); // avoid memory leak
}

template <class T>
void util_list<T>::push_back(T *ptr) {
	node *n = new node(ptr);
	if(!mHead) {
		mHead = n;
		mTail = n;
	} else {
		mTail->next = n;
		mTail = n;
	}
}

template <class T>
T *util_list<T>::pop_front(deleter pDeleter) {
	if(mHead) {
		node *n = mHead;
		T *data = n->data;
		mHead = mHead->next;
		if(!mHead) { // Hit the end
			mTail = NULL;
		}
		delete n;
		if(pDeleter) {
			pDeleter(data);
			data = NULL;
		}
		return data;
	}
	else {
		return NULL;
	}
}

template <class T>
void util_list<T>::remove(T *ptr) {
	// TODO: add support...
	(void)ptr;
}

template <class T>
void util_list<T>::clear(deleter pDeleter) {
	while(mHead) {
		pop_front(pDeleter);
	}
}

template <class T>
int util_list<T>::execute_list(func f, bool pCheckRet) {
	node *n = mHead;
	int ret;
	while(n) {
		ret = ((n->data)->*f)();
		if(pCheckRet && ret < 0) {
			return ret;
		}
		n = n->next;
	}
	return 0;
}
