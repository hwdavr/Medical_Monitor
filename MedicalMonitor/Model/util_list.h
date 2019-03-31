#pragma once
#include <cstddef>

template <class T>
class util_list
{
public:
	typedef int (T::*func)();
	typedef void (*deleter)(T*);
	util_list(deleter pDeleter = NULL);
	~util_list();
	void push_back(T *ptr);
	T *pop_front(deleter pDeleter = NULL);
	void remove(T *ptr);
	void clear(deleter pDeleter = NULL);
	int execute_list(func f, bool pCheckRet = true);
private:
	struct node {
		node(T *ptr=NULL): data(ptr), next(NULL) {}
		T *data;
		node *next;
	};
private:
	node *mHead;
	node *mTail;
	deleter mDeleter;

public:
	// Simple iterator implementation
	class iterator
	{
	public:
		iterator(util_list<T> *pUtilList): mUtilList(pUtilList),
			current(pUtilList->mHead) {}
		iterator &operator++() {
			if(current) {
				current = current->next;
			}
			return *this;
		}
        iterator operator++(int) {
            if(current) {
                current = current->next;
            }
            return *this;
        }
		T *operator*() {
			return current->data;
		}
		friend bool operator!=(const iterator &lhs, const iterator &rhs) {
			return (lhs.current != rhs.current);
		}
		friend util_list;
	private:
		util_list<T> *mUtilList;
		node *current;
	};
	iterator begin() {
		return iterator(this);
	}
	iterator end() {
		iterator i(this);
		i.current = NULL;
		return i;
	}
};

#include "util_list.tpp"
